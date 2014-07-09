require 'ghosty/settings'
require 'redis'

module Ghosty
  class Performer

    attr_reader :system
    attr_reader :track
    attr_reader :options

    def initialize(system, track, options = {})
      @system = system
      @track = track
      @options = options
    end

    def perform
      speaker = if options['speaker']
        system.speakers.find{|speaker| speaker.uid == options['speaker'] }
      else
        random_speaker
      end

      volume = options['volume'] || random_volume(speaker)

      isolated_from_group(speaker) do |speaker|
        return unless speaker

        results = speaker.voiceover!(track, volume)

        results.merge!(speaker: speaker.name, volume: volume, track: track)
      end
    end

    def isolated_from_group(speaker)
      old_group = system.groups.find{|group| group.slave_speakers.map(&:uid).include?(speaker.uid) }

      if old_group
        old_master = speaker.group_master
        old_group.disband
      end

      results = yield speaker

      if old_group
        old_group.slave_speakers.each do |speaker|
          speaker.join old_master
        end
      end

      results
    end

    def random_speaker
      speaker = system.speakers.select do |speaker|
        !speaker.is_playing? && speaker.uid != cache.get('ghosty.previous_uid')
      end.compact.sample

      cache.set('ghosty.previous_uid', speaker.uid) if speaker

      speaker
    end

    def random_volume(speaker)
      current_volume = speaker.volume

      if current_volume > 0
        (rand(current_volume) * 0.8).to_i
      else
        rand(15)
      end
    end

    def cache
      @cache ||= Redis.new
    end

  end
end
