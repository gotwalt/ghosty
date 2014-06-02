require 'celluloid'
require 'ghosty/ghost'
require 'addressable/uri'
require 'sonos_extensions'

module Ghosty
  class Scheduler
    include Celluloid

    VALID_HOURS = [20, 21, 22, 23, 0, 1, 2, 3]
    MIN_FREQUENCY = 45

    def initialize(base_uri, assets_directory)
      @base_uri = Addressable::URI.parse(base_uri)
      @assets_directory = assets_directory
      start
    end

    def start
      @system = Sonos::System.new

      loop do
        duration = (MIN_FREQUENCY + rand(120)) * 60
        puts "Scheduled for #{Time.now + duration}"
        sleep duration
        perform if VALID_HOURS.include?(Time.now.hour)
      end
    end

    def perform
      isolated_from_group(random_speaker) do |speaker|
        Ghosty::Ghost.new(speaker, random_track) if speaker
      end
    end

    def isolated_from_group(speaker)
      old_group = @system.groups.find{|group| group.slave_speakers.map(&:uid).include?(speaker.uid) }

      if old_group
        old_master = speaker.group_master
        old_group.disband
      end

      yield speaker

      if old_group
        old_group.slave_speakers.each do |speaker|
          speaker.join old_master
        end
      end
    end

    def random_speaker
      speaker = @system.speakers.select do |speaker|
        !speaker.playing? && speaker.uid != @previous_uid
      end.compact.sample

      @previous_uid = speaker.uid if speaker

      speaker
    end

    # Finds a file to play and returns it as a URI
    def random_track
      file = Dir.glob(File.join(@assets_directory, '*.mp3')).sample

      if file
        uri = @base_uri.dup
        uri.path = File.basename(file)
        uri.to_s
      end
    end
  end
end
