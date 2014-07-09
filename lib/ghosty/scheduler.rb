require 'ghosty/performer'
require 'ghosty/settings'
require 'addressable/uri'
require 'sonos'
require 'mono_logger'

module Ghosty
  class Scheduler

    attr_reader :system

    def initialize
      @system = Sonos::System.new

      trap("SIGINT") do
        logger.info 'Stopped'
        exit 130
      end
    end

    def start
      logger.info 'Started'

      loop do
        frequency = Ghosty::Settings.minimum_frequency
        wait_time = (frequency + rand(frequency * 4)) * 60

        logger.info "Scheduling for #{Time.now + wait_time}"

        sleep wait_time

        if Ghosty::Settings.valid_hours.include?(Time.now.hour)
          begin
            results = Ghosty::Performer.new(system, tracks.sample).perform
            logger.info "Played #{File.basename(results[:track])} on #{results[:speaker]} at volume #{results[:volume]} (#{results[:original_volume]})"
          rescue Savon::SOAPFault => ex
            logger.error "SOAP Error - #{ex.to_hash.inspect}"
          end
        else
          logger.info 'Skipping - time is out of bounds'
        end
      end
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
      @logger ||= MonoLogger.new(File.join(File.expand_path('../../../', __FILE__), 'ghosty.log'))
    end


  end
end
