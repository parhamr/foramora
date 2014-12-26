require 'yaml'

class Fora

  def self.forae
    @forae ||= YAML.load(ERB.new(File.binread('config/forae.yml')).result)['forae']
  end

  def self.detect_application(url)
  
  end
end
