require 'sonos'
require 'celluloid'
require 'addressable/uri'

module Ghosty
  class Player
    include Celluloid

    def initialize(base_uri, file_path)
      @uri = Addressable::URI.parse(base_uri)
      @path = File.join File.expand_path('../../../', __FILE__), file_path
      @system = Sonos::System.new
    end

    def select_speaker
      @system.speakers.map do |speaker|
        speaker if speaker.name == 'Office' # get_player_state[:state] == 'PAUSED_PLAYBACK'
      end.compact.sample
    end

    # Finds a file to play and returns it as a URI
    def select_file
      file = Dir.glob(File.join(@path, '*.mp3')).sample

      if file
        uri = @uri.dup
        uri.path = File.basename(file)
        uri.to_s
      end
    end

    def perform
      speaker = select_speaker
      file = select_file

      speaker.play(file)
      speaker.play
    end

  end
end
