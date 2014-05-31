require 'sonos'
require 'celluloid'
require 'addressable/uri'
require 'cgi'

module Ghosty
  class Player
    include Celluloid

    def initialize(base_uri, file_path)
      @uri = Addressable::URI.parse(base_uri)
      @path = File.join File.expand_path('../../../', __FILE__), file_path
      @system = Sonos::System.new
    end

    def perform
      speaker = random_speaker
      file = ghost_url

      previous = speaker.now_playing
      previous_uri = Addressable::URI.parse(previous[:uri])
      previous_uri.query = nil

      puts "Playing #{file} on #{speaker.name}"
      speaker.play(file)
      track_info = speaker.now_playing
      speaker.play

      # Determine the track length, add a few extra seconds for padding
      duration = Time.parse(track_info[:track_duration]).sec + 2
      puts "Sleeping for #{duration}s"
      sleep 0 # duration

      puts "Resetting speaker source to #{previous_uri}"
      # reset the current track
      speaker.play(previous_uri.to_s)
      speaker.play
    end

    private

    def random_speaker
      @system.speakers.map do |speaker|
        speaker #speaker.get_player_state[:state] == 'PAUSED_PLAYBACK'
      end.compact.sample
    end

    # Finds a file to play and returns it as a URI
    def ghost_url
      file = Dir.glob(File.join(@path, '*.mp3')).sample

      if file
        uri = @uri.dup
        uri.path = File.basename(file)
        uri.to_s
      end
    end

  end
end
