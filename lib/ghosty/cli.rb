require 'thor'
require 'celluloid'
require 'ghosty/web'

module Ghosty
  class Cli < Thor

    desc 'start', 'Runs the service'
    def start
      web = Ghosty::Web.new

      web.async.start
      puts 'starting timer'

      sleep
    end

  end
end
