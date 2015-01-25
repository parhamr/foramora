require 'faker'

#
class Mora
  attr_accessor :browsing_history,
    :created_at,
    :fora,
    :logger,
    :last_reply_at,
    :last_topic_at

  # FIXME: move to configurables
  FORA_BROWSING_PERIOD = 120
  TOPIC_READING_PERIOD = 2

  def initialize(*args)
    options = args.extract_options!
    @fora   = options[:fora]
    @logger = (fora.respond_to?(:logger) ? fora.logger : Logging.logger(STDOUT))
    @created_at = Time.now.utc
    @browsing_history = []
  end

  def simulate!
    browse!
    reply!
  end

  # Clicks around for a configurable wait period
  def browse!
    logger.info 'Browsing!'
    started_at = Time.now.utc
    ends_at = started_at + FORA_BROWSING_PERIOD
    # members like #<Selenium::WebDriver::Element:0x3ad5dc83eb40cd32 id="{bb7696fe-3f81-8847-89d3-d1141afbcc78}">
    if (topics = fora.topics('')).present?
      browsing_history << fora.driver.current_url
    end
    if topics.empty?
      logger.warn 'Zero topics found!'
    else
      starting_page_count = browsing_history.length
      logger.info "Current topics, default sort:\n#{topics.map { |t| "\t#{t.text}" }.join("\n")}"
      logger.info "Browsing until #{ends_at}"
      # browse for this period
      while ends_at > Time.now.utc
        fora.visit_random_topic
        browsing_history << fora.driver.current_url
        logger.debug "Reading for #{TOPIC_READING_PERIOD} seconds..."
        logger.info "viewing_my_topic? #{fora.viewing_my_topic?.inspect}"
        logger.info "my_replies: #{fora.my_replies.length}"
        logger.info "replies_to_me: #{fora.replies_to_me.length}"
        binding.pry
        sleep TOPIC_READING_PERIOD
      end
      logger.info 'Browsing completed!'
      logger.debug "URLs visited in #{FORA_BROWSING_PERIOD} seconds: #{browsing_history.length - starting_page_count}"
      logger.debug "Browsing history:\n#{browsing_history.inspect}"
    end
    true
  end

  # Posts a new topic
  def create_topic!
    fora.post_new_topic
  end

  def reply!
  end
end
