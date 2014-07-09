require 'mono_logger'

module Ghosty
  class Logger
    def self.info(message)
      instance.info(message)
    end

    def self.warn(message)
      instance.warn(message)
    end

    def self.debug(message)
      instance.debug(message)
    end

    def self.error(message)
      instance.error(message)
    end

    def self.instance
      @instance ||= MonoLogger.new(STDOUT)
    end

  end
end
