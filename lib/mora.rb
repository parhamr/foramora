#
class Mora
  attr_accessor :fora, :logger

  def initialize(*args)
    options = args.extract_options!
    @fora   = options[:fora]
    @logger = fora.logger
  end

  # Clicks around for 2x the new_topic wait period
  def browse!
    logger.debug 'Browse!'
    # members like #<Selenium::WebDriver::Element:0x3ad5dc83eb40cd32 id="{bb7696fe-3f81-8847-89d3-d1141afbcc78}">
    topics = fora.topics
    logger.info "Current topics, default sort:\n#{topics.map { |t| "\t#{t.text}" }.join("\n")}"
  end

  # Posts a new topic
  def create_topic!
  end
end
