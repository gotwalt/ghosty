require 'sonos_extensions'
require 'celluloid'
require 'cgi'

module Ghosty
  class Ghost
    attr_reader :speaker

    def initialize(speaker, track)

      @speaker = speaker.group_master

      save_state
      play(track)
      restore_state
    end

    def save_state
      speaker.pause if @was_playing = speaker.playing?
      speaker.unmute if @was_muted = speaker.muted?
      @previous_volume = speaker.volume
      @previous = speaker.now_playing
    end

    def play(track)
      puts "Playing track #{track} on speaker #{speaker.name}"

      speaker.volume = 10 + rand(15)

      # queue up the track
      speaker.play track

      # play it
      speaker.play

      # pause the thread until the track is done
      sleep(0.2) while speaker.playing?
    end

    def restore_state
      # the sonos app does this. I think it tells the player to think of the master queue as active again
      speaker.play speaker.uid.gsub('uuid', 'x-rincon-queue') + '#0'

      if @previous
        speaker.select_track @previous[:queue_position]
        speaker.seek Time.parse("1/1/1970 #{@previous[:current_position]} -0000" ).to_i

        speaker.volume = @previous_volume
        speaker.mute if @was_muted
      end

      speaker.play if @was_playing
    end


  end
end


