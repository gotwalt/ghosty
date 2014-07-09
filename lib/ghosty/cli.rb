require 'thor'
require 'irb'

module Ghosty
  class Cli < Thor

    desc 'daemon', 'Runs the service'
    def daemon
      Ghosty::Scheduler.new.start
    end

    desc 'trigger', 'Plays a single sound and then exits'
    def trigger
      p Ghosty::Scheduler.new.trigger
    end

    desc 'cli', 'Launches IRB instance with everything required'
    def cli
      ARGV.clear
      IRB.start
    end
  end
end
