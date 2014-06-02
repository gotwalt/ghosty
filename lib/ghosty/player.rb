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

      is_paused = ['PAUSED_PLAYBACK', 'STOPPED'].include?(speaker.get_player_state[:state])

      speaker.pause unless is_paused

      previous = speaker.now_playing

      puts "Playing #{file} on #{speaker.name}"
      speaker.play file

      speaker.play

      until ['PAUSED_PLAYBACK', 'STOPPED'].include?(speaker.get_player_state[:state])
        sleep 0.1
      end

      puts "Resetting speaker source"

      # the sonos app does this. I think it tells the player to think of the master queue as active again
      speaker.play speaker.uid.gsub('uuid', 'x-rincon-queue') + '#0'

      if previous
        speaker.select_track previous[:queue_position]
        speaker.seek Time.parse("1/1/1970 #{previous[:current_position]} -0000" ).sec
      end

      speaker.play unless is_paused
    end

    private


    def random_speaker
      @system.speakers.map do |speaker|
        speaker if speaker.name == 'Office' #speaker.get_player_state[:state] == 'PAUSED_PLAYBACK'
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

module Sonos::Endpoint::AVTransport
  def select_track(index)
    parse_response send_transport_message('Seek', "<Unit>TRACK_NR</Unit><Target>#{index}</Target>")
  end
end

