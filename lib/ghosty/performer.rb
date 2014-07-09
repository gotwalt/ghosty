module Ghosty
  class Performer

    attr_reader :system
    attr_reader :track
    attr_reader :cache

    def initialize(system, track, cache = {})
      @system = system
      @cache = cache
      @track = track
    end

    # Isolates a random speaker and plays the track.
    def perform
      isolated_from_group(random_speaker) do |independent_speaker|
        results = independent_speaker.voiceover!(track, volume)

        results.merge!(speaker: independent_speaker.name, volume: volume, track: track)
      end
    end

    # Isolates a speaker from any groups it might be in and yields it
    def isolated_from_group(speaker)
      old_group = system.groups.find{|group| group.slave_speakers.map(&:uid).include?(speaker.uid) }

      if old_group
        old_master = speaker.group_master
        old_group.disband
      end

      if speaker
        results = yield speaker
      end

      if old_group
        old_group.slave_speakers.each do |speaker|
          speaker.join old_master
        end
      end

      results
    end

    # Returns a cached randomly selected speaker that isn't currently playing and wasn't used on the last instantiation.
    def random_speaker
      @random_speaker ||= begin
        selected_speaker = system.speakers.select do |speaker|
          !speaker.is_playing? && speaker.uid != cache['ghosty.previous_uid']
        end.compact.sample

        cache['ghosty.previous_uid'] = selected_speaker.nil? ? nil : selected_speaker.uid

        selected_speaker
      end
    end

    # Picks a random volume for the random speaker that's less than its current volume. If the speaker is currently at zero,
    # it picks a volume between 0-15.
    def volume
      @volume ||= begin
        current_volume = random_speaker.volume

        if current_volume > 0
          (rand(current_volume) * 0.8).to_i
        else
          rand(15)
        end
      end
    end
  end
end
