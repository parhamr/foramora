require 'faker'

#
class Mora
  include ::ActionView::Helpers::TextHelper

  attr_accessor :browsing_history,
    :created_at,
    :fora,
    :logger,
    :last_reply_at,
    :last_topic_at

  # FIXME: move to configurables
  FORA_BROWSING_PERIOD = 120
  TOPIC_READING_PERIOD = 1

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
  # REVIEW: do these procedural things belong in a scripting layer? this isn't a concern of the mora
  def browse!
    logger.info 'Browsing!'
    started_at = Time.now.utc
    ends_at = started_at + FORA_BROWSING_PERIOD
    # members like #<Selenium::WebDriver::Element:0x3ad5dc83eb40cd32 id="{bb7696fe-3f81-8847-89d3-d1141afbcc78}">
    if (topics = fora.topics('')).present?
      browsing_history << fora.driver.current_url
    end
    starting_page_count = browsing_history.length
    if topics.empty?
      logger.warn 'Zero topics found!'
    else
      logger.debug "Current topics, default sort:\n#{topics.map { |t| "\t#{t.text}" }.join("\n")}"
      logger.warn "Browsing until #{ends_at}"
      # browse for this period
      while ends_at > Time.now.utc
        # NOTE: network call, this can raise exception
        fora.visit_random_topic
        browsing_history << fora.driver.current_url
        read_this_page
      end
      logger.info 'Browsing completed!'
      logger.info "URLs visited in #{FORA_BROWSING_PERIOD} seconds: #{browsing_history.length - starting_page_count}"
      logger.debug "Browsing history:\n#{browsing_history.inspect}"
    end
    true
  end

  # Posts a new topic
  def create_topic!
    fora.post_new_topic
  end

  def reply!(options = {})
  end

  def read_this_page
    start_time = Time.now.utc.to_f
    logger.debug 'Reading current page...'
    unless topic_is_locked?
      viewing_my_topic?
      check_my_replies
    end
    elapsed_time = (Time.now.utc.to_f - start_time)
    logger.info "Page took #{pluralize(elapsed_time, 'second')} to read."
    if elapsed_time < TOPIC_READING_PERIOD
      sleep_time = TOPIC_READING_PERIOD - elapsed_time
      logger.debug "Continuing to read for #{pluralize(sleep_time, 'second')}"
      sleep sleep_time
    end
  end

  def topic_is_locked?
    fora.topic_is_locked?
  end

  def viewing_a_topic_page?
    fora.viewing_a_topic?
  end

  def viewing_my_topic?
    logger.debug 'Viewing my topic?'
    if (my_topic = fora.viewing_my_topic?)
      logger.info 'This is my topic!'
      true
    else
      logger.info 'This is not my topic.'
      false
    end
  end

  def check_my_replies
    if fora.topic_is_locked?
      logger.warn 'Topic is locked!'
    else
      # NOTE: my_replies is not a cached lookup
      my_replies = fora.my_replies.dup
      # NOTE: replies_to_me is not a cached lookup
      replies_to_me = fora.replies_to_me.dup
      logger.info "Replies in this topic written by me: #{my_replies.try(:length).to_i}"
      logger.info "Replies in this topic addressed to me: #{replies_to_me.try(:length).to_i}"
      if my_replies.try(:length).to_i > 0
        # what to do about my replies?
      end
      if replies_to_me.try(:length).to_i > 0
        # TODO: continue the conversation?
        # binding.pry
      end
    end
    true
  end

  def locked_topic?
    false
  end
end
