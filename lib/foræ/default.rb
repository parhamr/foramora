module Foræ
  #
  class ::Foræ::Default
    attr_accessor :fora, :logger

    def initialize(*args)
      options = args.extract_options!
      @fora = options[:fora]
      @logger = fora.logger
    end

    def driver
      fora.try(:driver)
    end

    def topics_at(url)
      logger.debug "Finding current topics at: #{url}"
      driver.get url.to_s
      driver.find_elements :css, @fora.selectors[:topics_links]
    end
  end
end
