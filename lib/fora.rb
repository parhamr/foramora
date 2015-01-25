require 'logging'
require 'yaml'
require 'highline/import'
require 'curb'
require 'selenium-webdriver'

# An abstract representation of a fora
class Fora
  attr_accessor :app_root,
    :logger,
    :client,
    :driver,
    :dom_selectors,
    :fora,
    :fqdn,
    :platform,
    :secure

  # class

  def self.foræ
    @foræ ||= YAML.load(ERB.new(File.binread('config/foræ.yaml')).result)['foræ']
  end

  def self.platforms
    @platforms ||= YAML.load(ERB.new(File.binread('config/patterns.yaml')).result)[:platforms]
  end

  def self.test_uris
    @test_uris ||= platforms.map { |p| p[:test].merge(name: p[:name]) }
  end

  def self.select_target
    puts "Available foræ:\n\t#{self.foræ.each_with_index.map { |f, i| "#{i}) #{f[:fqdn]}" }.join("\n\t")}"
    selection = ask('Which fora would you like to use? ', Integer) do |q|
      # validates response is within bounds
      q.in = (0..(foræ.length - 1))
    end
    new(foræ[selection])
  end

  # instance

  def initialize(*args)
    options        = args.extract_options!.with_indifferent_access
    # subdomain, domain, tld
    @fqdn          = options[:fqdn]
    # remember the main configuration object
    @fora          = self.class.foræ.detect { |f| f[:fqdn] == fqdn }
    raise 'Fora not found!' if @fora.blank?
    @logger        = Logging.logger(@fora[:log_to].present? ? @fora[:log_to] : STDOUT)
    logger.level   = (@fora[:log_level].present? ? @fora[:log_level] : :warn)
    @driver        = Selenium::WebDriver.for options[:driver]
    # https?
    @secure        = options[:secure]
    # only if it violates the norm (80 or 443)
    @port          = options[:port]
    # path to the fora, from the fqdn (include forward slash)
    @app_root      = options[:app_root]

    @dom_selectors = options.fetch(:dom_selectors, {})

    begin
      require_relative "foræ/#{@fora[:type].underscore.downcase}"
    rescue LoadError => e
      logger.error "#{e.class}: #{e.message} (#{e.backtrace[0]})"
      teardown
      false
    end
    @platform      = "Foræ::#{@fora[:type]}".constantize.new(fora: self)
    logger.debug "Fora initialized! #{inspect}"
  end

  def teardown
    logger.info "Tearing down the #{fqdn} fora…"
    client.try(:close)
    driver.try(:quit)
    # always return true
    true
  end

  def url_for(*args)
    options  = args.extract_options!.with_indifferent_access
    # leading colon
    port     = options[:port].blank? ? nil : ":#{options[:port]}"
    # leading question mark
    query    = options[:query].blank? ? nil : "?#{options[:query]}"
    # leading octothorpe
    fragment = options[:fragment].blank? ? nil : "##{options[:fragment]}"
    URI("#{url_scheme}://#{fqdn}#{port}#{app_root}#{options[:path]}#{query}#{fragment}")
  end

  # interface only; the platform is the source of authority
  def topics(path=nil)
    # NOTE: root url
    platform.topics_at url_for(path: path.to_s)
  end

  def visit(path=nil)
    platform.visit url_for(path: path.to_s)
  end

  def visit_random_topic
    platform.visit_random_topic
  end

  def wait_times
    @wait_times ||= @fora.fetch(:waits, {})
  end

  def test
    base_url = url_for(path: '')
    logger.debug "Testing the #{fqdn} fora"
    client.url = base_url.to_s
    begin
      # this is network library code; it MUST be rescued
      client.perform
      if client.response_code >= 300
        logger.error "HTTP code not as expected! (#{client.response_code})"
      end
    rescue => e
      # log the problem and move on
      logger.fatal "#{e.class}: #{e.message} (#{e.backtrace[0]})"
    end
    logger.info client.status.to_s
    logger.debug client.header_str.to_s
    # REVIEW: this netcode might need to be rescued
    driver.get base_url.to_s
    logger.info "#{driver.title} (#{base_url})"
    logger.debug "Cookies:\n" + cookies.map { |cookie| "\t#{cookie[:name]} => #{cookie[:value]}" }.join("\n")
  end

  protected

  def client
    @client ||= Curl::Easy.new
  end

  def cookies
    driver.manage.all_cookies
  end

  private

  def url_scheme
    secure ? 'https' : 'http'
  end
end
