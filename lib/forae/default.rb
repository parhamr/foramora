# encoding: UTF-8
# coding: UTF-8
# -*- coding: UTF-8 -*-

module Forae
  # abstracted and common behaviors for each fora platform
  # external interactions use through this class
  # interactions are bidirectional; post and request content here
  class Default
    attr_accessor :fora,
      :known_topics,
      :logger,
      :indices,
      :topic_page_selector,
      :locked_topic_selector,
      :my_topic_selector,
      :my_replies_selector,
      :replies_to_me_selector,
      :current_url

    # NOTE: options has needs the minimal requirements; see forae.example.yaml
    def initialize(*args)
      options =       args.extract_options!
      @fora =         options[:fora]
      @logger =       fora.logger
      @known_topics = {}
      logger.debug    "#{self.class} initialized! #{inspect}"
    end

    delegate :driver, to: :fora, allow_nil: true

    # NOTE: the remote resource is expected to change; be careful with caches
    def topics_at(url)
      logger.info 'Finding current topics...'
      visit url
      topic_elements = if topics_links_selector.blank?
                         logger.warn "zero DOM selectors defined for #{@fora.fqdn}!"
                         []
                       else
                         call_driver_finder(topics_links_selector.merge(selector_name: :topics_links_selector))
                       end
      store_topics topic_elements
    end

    # HTTP GET requests
    def visit(url)
      logger.info "Loading #{url}"
      driver.get url.to_s
      logger.info "#{driver.title.inspect}"
      # NOTE: updated after calling so exceptions skip the assignment
      current_url = url
      ingest_content
      # common: Errno::ECONNREFUSED
    rescue => e
      logger.error "Failed to load! #{e.class}: #{e.message} (#{e.backtrace[0]})"
    end

    #
    def visit_random_topic
      logger.info 'Visiting random topic...'
      # TODO: store a cache of the properties of the chosen topic
      visit known_topics.keys.sample
    end

    def start_new_topic
      # TODO
    end

    def viewing_a_topic?
      logger.info 'Checking if this is a topic...'
      topic_element = if topic_page_selector.blank?
                        logger.warn "No XPath selectors found for 'topic page'"
                        nil
                      else
                        call_driver_finder(topic_page_selector.merge(selector_name: :topic_page_selector))
                      end
      if topic_element.present?
        logger.info 'This is a topic!'
        true
      else
        logger.info 'Not viewing a topic page.'
        false
      end
    end

    # NOTE: returns true when the current page might not be a topic
    def topic_is_locked?
      locked_topic_element = if viewing_a_topic?
                               logger.info 'Checking if this topic is locked...'
                               if locked_topic_selector.blank?
                                 logger.warn "No XPath selectors found for 'locked topic'"
                                 false
                               else
                                 call_driver_finder(locked_topic_selector.merge(selector_name: :locked_topic_selector))
                               end
                             end
      if locked_topic_element.present?
        logger.warn 'This is a locked topic.'
        true
      elsif locked_topic_element.nil?
        logger.warn 'This might not be a topic page.'
        true
      else
        logger.warn 'This topic is not locked.'
        false
      end
    end

    # does the current page show I am the author?
    def viewing_my_topic?
      logger.info 'Checking if this is my topic...'
      returning = if my_topic_selector.blank?
                    logger.warn "No XPath selectors found for 'my topic'"
                    # Default to empty object
                    nil
                  else
                    call_driver_finder(my_topic_selector.merge(selector_name: :my_topic_selector))
                  end
      logger.info((returning ? 'This is my topic!' : 'This is not my topic.'))
      returning
    end

    # selection from current page of replies written by me
    def my_replies
      logger.info 'Looking for replies I have written...'
      if my_replies_selector.blank?
        logger.warn "No XPath selectors found for 'my replies'"
        # Default to empty set
        []
      else
        call_driver_finder(my_replies_selector.merge(selector_name: :my_replies_selector))
      end
    end

    # selection from current page of replies written toward me
    def replies_to_me
      logger.info 'Checking for replies to my posts...'
      if replies_to_me_selector.blank?
        logger.warn "No XPath selectors found for 'my topic'"
        # Default to empty set
        []
      else
        call_driver_finder(replies_to_me_selector.merge(selector_name: :replies_to_me_selector))
      end
    end

    protected

    # take the topics seen and add them to the known topics
    # NOTE: moderate risk of huge memory allocations for large forae
    def store_topics(topic_elements)
      logger.info 'Storing topics...'
      # logger.debug topic_elements.inspect
      previous_topics_count = known_topics.try(:length).to_i
      found_topics_count = topic_elements.try(:length).to_i
      if found_topics_count > 0
        logger.info "Topics found: #{found_topics_count}"
        topic_elements.each do |element|
          # assume URLs are unique identifiers
          if (url = element[:href]).present?
            # logger.debug "Element: #{element.instance_variables.inspect}"
            known_topics[url] = known_topics.fetch(url, {}).merge(
              id:            element.instance_variable_get(:@id),
              link_text:     element.text,
              enabled:       element.enabled?,
              displayed:     element.displayed?,
              replies_count: nil, # unknown, for now
              locked?:       nil, # unknown, for now
              mine?:         nil, # unknown, for now
            )
          else
            logger.warn "href attribute not found for element: #{element.inspect}"
          end
        end
      end
      found_topics_count = known_topics.length - previous_topics_count
      logger.info "New topics added to memory: #{found_topics_count}"
      topic_elements
    end

    def topic_page_selector
      @topic_page_selector ||= fora.dom_selectors.
                               fetch(:topic_page, {}).
                               try(:with_indifferent_access)
    end

    def topics_links_selector
      @topics_links_selector ||= fora.dom_selectors.
                                 fetch(:topics_links, {}).
                                 try(:with_indifferent_access)
    end

    def my_topic_selector
      @my_topic_selector ||= fora.dom_selectors.
                             fetch(:my_topic, {}).
                             try(:with_indifferent_access)
    end

    def my_replies_selector
      @my_replies_selector ||= fora.dom_selectors.
                               fetch(:my_replies, {}).
                               try(:with_indifferent_access)
    end

    def replies_to_me_selector
      @replies_to_me_selector ||= fora.dom_selectors.
                                  fetch(:replies_to_me, {}).
                                  try(:with_indifferent_access)
    end

    def locked_topic_selector
      @locked_topic_selector ||= fora.dom_selectors.
                                 fetch(:locked_topic, {}).
                                 try(:with_indifferent_access)
    end

    private

    def call_driver_finder(selector_config)
      logger.debug "#call_driver_finder called with: #{selector_config.inspect}"
      unless selector_config.respond_to?(:fetch)
        msg = "Options should respond to #fetch; class #{selector_config.class} does not"
        logger.fatal msg
        raise ArgumentError, msg
      end
      returning = nil
      selector_config.with_indifferent_access
      # TODO: validate expression when type is :xpath?
      search_type = selector_config.fetch(:type, :css)
      logger.debug "search_type: #{search_type.inspect} (#{search_type.class})"
      search_expression = selector_config.fetch(:expression, nil)
      logger.debug "search_expression: #{search_expression.inspect} (#{search_expression.class})"
      search_returns = selector_config.fetch(:returns, :many)
      logger.debug "search_returns: #{search_returns.inspect} (#{search_returns.class})"
      returning = case search_expression
                  when Array
                    # minor recursion!
                    search_expression.each do |e|
                      call_driver_finder(
                        type:       search_type,
                        expression: e.to_s,
                        returns:    search_returns
                      )
                    end
                  when String, Symbol
                    case search_returns.to_s
                    when 'one'
                      driver.find_element(search_type, search_expression)
                    when 'many'
                      driver.find_elements(search_type, search_expression)
                    else
                      msg = "Invalid :returns received (:one or :many expected): #{search_returns.inspect}"
                      logger.fatal msg
                      raise ArgumentError, msg
                    end
                  else
                    msg = "Invalid expression received (Array, Symbol, or String expected): #{search_expression.class}"
                    logger.fatal msg
                    raise ArgumentError, msg
                  end
      returning
    rescue Selenium::WebDriver::Error::NoSuchElementError => e
      # Normal! This query didn’t find anything
      logger.info "#{e.class}: #{e.message}"
      false
    rescue Selenium::WebDriver::Error::InvalidSelectorError => e
      # Abnormal! This query should be fixed
      logger.error "#{e.class}: #{e.message}"
      nil
    end

    def ingest_content
      # store: driver.page_source
    end
  end
end
