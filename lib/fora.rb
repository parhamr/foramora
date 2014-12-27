require 'logging'
require 'yaml'
require 'highline/import'
require 'curb'

# An abstract representation of a fora
class Fora

  attr_accessor :logger, :client, :driver, :fora, :fqdn, :secure, :platform, :app_root

  # class

  def self.foræ
    @foræ ||= YAML.load(ERB.new(File.binread('config/foræ.yml')).result)['foræ']
  end

  def self.test_uris
    @test_uris ||= YAML.load(ERB.new(File.binread('config/patterns.yml')).result)['test_uris']
  end

  def self.platforms
    @platforms ||= YAML.load(ERB.new(File.binread('config/patterns.yml')).result)['platforms']
  end

  def self.select_application
    puts "Available foræ:\n\t#{self.foræ.each_with_index.map{|f,i| "#{i}) #{f['fqdn']}"}.join("\n\t")}"
    selection = ask("Which fora would you like to use? ", Integer) do |q|
      q.in = (0..(foræ.length - 1))
    end
    new(foræ[selection])
  end

  # instance

  def initialize(*args)
    options      = args.extract_options!
    # subdomain, domain, tld
    @fqdn        = options['fqdn']
    # remember the main configuration object
    @fora        = self.class.foræ.detect { |f| f['fqdn'] == fqdn }
    raise 'Fora not found!' if @fora.blank?
    
    @logger      = Logging.logger (@fora['log_to'].present? ? @fora['log_to'] : STDOUT)
    logger.level = (@fora['log_level'].present? ? @fora['log_level'] : :warn)
    
    @driver      = Selenium::WebDriver.for options['driver']
    @client      = Curl::Easy.new
    #@platform    = "Foræ::#{@fora['type']}".constantize.new
    # https?
    @secure      = options['secure']
    # only if it violates the norm (80 or 443)
    @port        = options['port']
    # path to the fora, from the fqdn (include forward slash)
    @app_root    = options['app_root']
    logger.debug "Fora initialized! #{self.inspect}"
    test
  end

  def teardown
    logger.debug "Tearing down the #{fqdn} fora…"
    client.close
    driver.quit
  end

  def cookies
    driver.manage.all_cookies
  end

  protected

  def url_for(*args)
    options  = args.extract_options!
    scheme   = secure ? 'https' : 'http'
    # leading colon
    port     = options['port'].blank? ? nil : ":#{options['port']}"
    # leading question mark
    query    = options['query'].blank? ? nil : "?#{options['query']}"
    # leading octothorpe
    fragment = options['fragment'].blank? ? nil : "##{options['fragment']}"
    URI("#{scheme}://#{fqdn}#{port}#{app_root}#{options['path']}#{query}#{fragment}")
  end

  def test
    base_url = url_for(path: '')
    logger.debug "Testing the #{fqdn} fora"
    client.url = base_url.to_s
    client.perform
    logger.info "#{client.status}"
    logger.debug "#{client.header_str}"
    driver.get base_url.to_s
    logger.info "#{driver.title} (#{base_url})"
    logger.debug "Cookies:\n" + cookies.map { |cookie| "\t#{cookie[:name]} => #{cookie[:value]}" }.join("\n")
  end

end
