require 'thor'
require 'ghosty/scheduler'
require 'ghosty/settings'

module Ghosty
  class Cli < Thor

    desc 'start', 'Runs the service'
    def start
      Ghosty::Scheduler.new.start
    end
  end
end
