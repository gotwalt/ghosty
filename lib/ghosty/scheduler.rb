require 'celluloid'
require 'ghosty/ghost'
require 'addressable/uri'

module Ghosty
  class Scheduler
    include Celluloid

    def initialize(base_uri, assets_directory)
      @base_uri = Addressable::URI.parse(base_uri)
      @assets_directory = assets_directory
      start
    end

    def start
      puts 'Starting scheduler'
      @system = Sonos::System.new
      perform
    end

    def perform
      puts 'Adding ghost'
      isolated_from_group(random_speaker) do |speaker|
        Ghosty::Ghost.new(speaker, random_track)
      end
    end

    def isolated_from_group(speaker)
      puts 'Isolating speaker from group'
      old_group = @system.groups.find{|group| group.slave_speakers.map(&:uid).include?(speaker.uid) }

      if old_group
        old_master = speaker.group_master
        old_group.disband
      end

      yield speaker

      puts 'Resetting group'
      if old_group
        old_group.slave_speakers.each do |speaker|
          speaker.join old_master
        end
      end
    end

    def random_speaker
      @system.speakers.map do |speaker|
        speaker if speaker.name == 'Office' #speaker.get_player_state[:state] == 'PAUSED_PLAYBACK'
      end.compact.sample
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
