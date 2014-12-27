module Foræ
  class MiniBBS

    attr_accessor :fora, :logger

    def initialize(*args)
      options = args.extract_options!
      @fora = options[:fora]
      @logger = fora.logger
    end

    def driver
      fora.driver
    end

    def threads_at(url)
      logger.debug "Finding current threads at: #{url}"
      driver.get url.to_s
      driver.find_elements :css, '#body_wrapper .topic_headline a'
    end
  end
end
