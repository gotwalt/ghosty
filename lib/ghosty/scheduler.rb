require 'ghosty/performer'
require 'ghosty/settings'
require 'addressable/uri'
require 'sonos'
require 'logger'

module Ghosty
  class Scheduler

    VALID_HOURS = [20, 21, 22, 23, 0, 1, 2, 3]
    MIN_FREQUENCY = 45

    attr_reader :system

    def initialize
      @system = Sonos::System.new
    end

    def start
      #loop do
        duration = (MIN_FREQUENCY + rand(120)) * 60
        puts "Scheduled for #{Time.now + duration}"
        #sleep duration
        perform #if VALID_HOURS.include?(Time.now.hour)
      #end
    end

    def perform
      result = Ghosty::Performer.new(system, tracks.sample).perform
      logger.info result.inspect
    end

    def tracks
      @tracks ||= begin
        ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
        base_uri = "http://#{ip}:#{Ghosty::Settings.port}/"
        assets_directory = File.join File.expand_path('../../../', __FILE__), 'assets'
        Dir.glob(File.join(assets_directory, '*.mp3')).map do |file|
          base_uri + File.basename(file)
        end
      end
    end

    def logger
      @logger ||= Logger.new(File.join(File.expand_path('../../../', __FILE__), 'ghosty.log'))
    end


  end
end
