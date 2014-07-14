require 'sonos'

module Ghosty
  # Schedules and manages running performers, maintains state.
  class Scheduler

    attr_reader :system
    attr_reader :cache

    def initialize
      @system = Sonos::System.new
      @cache = {}
    end

    # Runs the ghost scheduler in a loop
    def start
      Ghosty::Logger.info 'Started'

      # Handle Control-C signals that may occur while sleeping
      trap("SIGINT") do
        Ghosty::Logger.info 'Stopped'
        return
      end

      loop do
        frequency = Ghosty::Settings.minimum_frequency
        wait_time = (frequency + rand(frequency * 4)) * 60

        Ghosty::Logger.info "Scheduling for #{Time.now + wait_time}"

        sleep(wait_time)

        if Ghosty::Settings.valid_hours.include?(Time.now.hour)
          trigger
        else
          Ghosty::Logger.info 'Skipping - time is out of bounds'
        end
      end
    end

    # Fires off a performer to play a random track
    def trigger
      begin
        results = Ghosty::Performer.new(system, tracks.sample, cache).perform
        Ghosty::Logger.info "Played #{File.basename(results[:track])} on #{results[:speaker]} at volume #{results[:volume]} (#{results[:original_volume]})"
      rescue Savon::SOAPFault => ex
        Ghosty::Logger.error "SOAP Error - #{ex.to_hash.inspect}"
      end

      results
    end

    # Returns a cached list of track URLs
    def tracks
      @tracks ||= begin
        assets_directory = File.join File.expand_path('../../../', __FILE__), 'assets'

        Dir.glob(File.join(assets_directory, '*.mp3')).map do |file|
          "http://#{ip}:#{Ghosty::Settings.port}/#{File.basename(file)}"
        end
      end
    end

    # Returns the IP of the executing machine
    def ip
      @ip ||= Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
    end

  end
end
