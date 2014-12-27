require 'yaml'
require 'highline/import'

class Fora

  include

  attr_accessor :driver, :fqdn, :secure, :path

  def self.forae
    @forae ||= YAML.load(ERB.new(File.binread('config/forae.yml')).result)['forae']
  end

  def self.test_uris
    @test_uris ||= YAML.load(ERB.new(File.binread('config/patterns.yml')).result)['test_uris']
  end

  def self.detect_application(url)
  
  end

  def self.select_application
    puts "Available foræ:\n\t#{self.forae.each_with_index.map{|f,i| "#{i}) #{f['fqdn']}"}.join("\n\t")}"
    selection = ask("Which fora would you like to use? ", Integer) do |q|
      q.in = (0..(forae.length - 1))
    end
    new(forae[selection])
  end

  def initialize(*args)
    options = args.extract_options!
    @driver = Selenium::WebDriver.for options['driver']
    @fqdn   = options['fqdn']
    @secure = options['secure']
    @path   = options['path']
    test
  end

  def test
    driver.get(url_for(path: '/').to_s)
  end

  def url_for(*args)
    options  = args.extract_options!
    scheme = secure ? 'https' : 'http'
    # leading question mark
    query    = options['query'].blank? ? nil : "?#{options['query']}"
    # leading octothorpe
    fragment = options['fragment'].blank? ? nil : "##{options['fragment']}"
    URI("#{scheme}://#{fqdn}/#{options['path']}#{query}#{fragment}")
  end
end
