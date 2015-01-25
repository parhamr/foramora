module Foræ
  #
  class ::Foræ::Default
    attr_accessor :fora, :logger, :known_topics

    def initialize(*args)
      options = args.extract_options!
      @fora = options[:fora]
      @logger = fora.logger
      @known_topics = {}
    end

    def driver
      fora.try(:driver)
    end

    # NOTE: the remote resource is expected to change; be careful with caches
    def topics_at(url)
      logger.info "Finding current topics..."
      visit(url)
      topic_elements = if @fora.dom_selectors.blank?
                         logger.warn "zero DOM selectors defined for #{@fora.fqdn}!"
                         []
                       else
                         driver.find_elements :css, @fora.dom_selectors[:topics_links]
                       end
      store_topics(topic_elements)
    end

    def visit(url)
      begin
        logger.info "Loading #{url}"
        driver.get url.to_s
        logger.info "#{driver.title.inspect}"
        # common: Errno::ECONNREFUSED
      rescue => e
        logger.error "Failed to load! #{e.class}: #{e.message} (#{e.backtrace[0]})"
      end
    end

    def visit_random_topic
      logger.info "Visiting random topic..."
      visit known_topics.keys.sample
    end

    protected

    # take the topics seen and add them to the known topics
    # NOTE: moderate risk of huge memory allocations for large foræ
    def store_topics(topic_elements)
      logger.info "Storing topics..."
      # logger.debug topic_elements.inspect
      topic_elements.each do |element|
        # assume URLs are unique identifiers
        if (url = element[:href]).present?
          # logger.debug "Element: #{element.instance_variables.inspect}"
          known_topics[url] = known_topics.fetch(url, {}).merge(
            id:        element.instance_variable_get(:@id),
            link_text: element.text,
            enabled:   element.enabled?,
            displayed: element.displayed?
          )
        else
          logger.info "href not found for element: #{element.inspect}"
        end
      end
      # logger.debug "Known topics:\n#{known_topics.inspect}"
      topic_elements
    end
  end
end
