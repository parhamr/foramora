module Foræ
  #
  class ::Foræ::Default
    attr_accessor :fora,
      :known_topics,
      :logger,
      :my_topic_selectors,
      :my_replies_selector,
      :replies_to_me_selector

    def initialize(*args)
      options = args.extract_options!
      @fora = options[:fora]
      @logger = fora.logger
      @known_topics = {}
    end

    delegate :driver, to: :fora, allow_nil: true

    # NOTE: the remote resource is expected to change; be careful with caches
    def topics_at(url)
      logger.info 'Finding current topics...'
      visit(url)
      topic_elements = if topics_links_selector.blank?
                         logger.warn "zero DOM selectors defined for #{@fora.fqdn}!"
                         []
                       else
                         call_driver_finder(topics_links_selector)
                       end
      store_topics(topic_elements)
    end

    def visit(url)
      logger.info "Loading #{url}"
      driver.get url.to_s
      logger.info "#{driver.title.inspect}"
      # common: Errno::ECONNREFUSED
    rescue => e
      logger.error "Failed to load! #{e.class}: #{e.message} (#{e.backtrace[0]})"
    end

    def visit_random_topic
      logger.info 'Visiting random topic...'
      visit known_topics.keys.sample
    end

    def start_new_topic
    end

    # does the current page show I am the author?
    def viewing_my_topic?
      if my_topic_selectors.blank?
        logger.warn "No XPath selectors found for 'my topic'"
        nil
      else
        call_driver_finder(my_replies_selector)
      end
    end

    # selection from current page of replies written by me
    def my_replies
      if my_replies_selector.blank?
        logger.warn "No XPath selectors found for 'my replies'"
        []
      else
        call_driver_finder(my_replies_selector)
      end
    end

    # selection from current page of replies written toward me
    def replies_to_me
      if replies_to_me_selector.blank?
        logger.warn "No XPath selectors found for 'my topic'"
        []
      else
        call_driver_finder(replies_to_me_selector)
      end
    end

    protected

    # take the topics seen and add them to the known topics
    # NOTE: moderate risk of huge memory allocations for large foræ
    def store_topics(topic_elements)
      logger.info 'Storing topics...'
      # logger.debug topic_elements.inspect
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
          logger.info "href not found for element: #{element.inspect}"
        end
      end
      # logger.debug "Known topics:\n#{known_topics.inspect}"
      topic_elements
    end

    def topics_links_selector
      @topics_links_selector ||= fora.dom_selectors.fetch(:topics_links, {}).try(:with_indifferent_access)
    end

    def my_topic_selector
      @my_topic_selector ||= fora.dom_selectors.fetch(:my_topic, {}).try(:with_indifferent_access)
    end

    def my_replies_selector
      @my_replies_selector ||= fora.dom_selectors.fetch(:my_replies, {}).try(:with_indifferent_access)
    end

    def replies_to_me_selector
      @replies_to_me_selector ||= fora.dom_selectors.fetch(:replies_to_me, {}).try(:with_indifferent_access)
    end

    private

    def call_driver_finder(selector_config)
      logger.debug "#call_driver_finder called with: #{selector_config.inspect}"
      unless selector_config.respond_to?(:fetch)
        raise ArgumentError, "Options should respond to #fetch; class #{selector_config.class} does not"
      end
      search_type = selector_config.fetch(:type, :css)
      logger.debug "search_type: #{search_type.inspect}"
      search_expression = selector_config.fetch(:expression, nil)
      logger.debug "search_expression: #{search_expression.inspect}"
      search_returns = selector_config.fetch(:returns, :many)
      logger.debug "search_returns: #{search_returns.inspect}"
      case search_expression
      when Array
        # minor recursion!
        search_expression.each do |e|
          call_driver_finder(
            type:       search_type,
            expression: e.to_s,
            returns:    search_returns
          )
        end
      when String
        case search_returns
        when :one
          driver.find_element(search_type, search_expression)
        when :many
          driver.find_elements(search_type, search_expression)
        else
          raise ArgumentError, "Invalid :returns received (:one or :many expected): #{search_returns.inspect}"
        end
      else
        raise ArgumentError, "Invalid expression received (Array or String expected): #{selector_config.inspect}"
      end
    rescue Selenium::WebDriver::Error::InvalidSelectorError => e
      logger.error "#{e.class}: #{e.message}"
      nil
    end
  end
end
