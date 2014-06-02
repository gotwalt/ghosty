require 'thor'
require 'ghosty/web'
require 'ghosty/scheduler'

Celluloid.logger = nil

module Ghosty
  class Cli < Thor

    desc 'start', 'Runs the service'
    def start

      assets_directory = File.join File.expand_path('../../../', __FILE__), 'assets'
      port = 3100
      base_uri = "http://#{IPSocket.getaddress(Socket.gethostname)}:#{port}"

      web = Ghosty::Web.new(assets_directory, port)
      web.async.start

      # Wait for the web to start
      sleep 1

      Ghosty::Scheduler.new(base_uri, assets_directory)

      # Final sleep is to keep things alive
      sleep 20
    end

  end
end
