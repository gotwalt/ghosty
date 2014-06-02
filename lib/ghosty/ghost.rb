require 'sonos'
require 'celluloid'
require 'cgi'

module Ghosty
  class Ghost
    attr_reader :speaker

    def initialize(speaker, track)
      puts 'Initializing ghost'

      @speaker = speaker.group_master

      save_state
      play(track)
      restore_state
    end

    def save_state
      puts 'Saving speaker state'
      speaker.pause if @was_playing = playing?
      @previous = speaker.now_playing
    end

    def play(track)
      puts "Playing track #{track} on speaker #{speaker.name}"

      # queue up the track
      speaker.play track

      # play it
      speaker.play

      # pause the thread until the track is done
      sleep(0.2) while playing?
    end

    def restore_state
      puts 'Restoring state'
      # the sonos app does this. I think it tells the player to think of the master queue as active again
      speaker.play speaker.uid.gsub('uuid', 'x-rincon-queue') + '#0'

      if @previous
        speaker.select_track @previous[:queue_position]
        speaker.seek Time.parse("1/1/1970 #{@previous[:current_position]} -0000" ).to_i
      end

      speaker.play if @was_playing
    end

    def playing?
      state = speaker.get_player_state[:state]
      !['PAUSED_PLAYBACK', 'STOPPED'].include?(state)
    end

  end
end

module Sonos::Endpoint::AVTransport
  def select_track(index)
    parse_response send_transport_message('Seek', "<Unit>TRACK_NR</Unit><Target>#{index}</Target>")
  end
end

