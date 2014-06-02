require 'thor'
require 'ghosty/web'
require 'ghosty/player'

module Ghosty
  class Cli < Thor

    desc 'start', 'Runs the service'
    def start

      port = 3100
      assets_directory = 'assets'
      base_uri = "http://#{IPSocket.getaddress(Socket.gethostname)}:#{port}"

      web = Ghosty::Web.new(assets_directory, port)
      web.async.start

      # Wait for the web to start
      sleep 1

      player = Ghosty::Player.new(base_uri, assets_directory)
      player.async.perform

      # Final sleep is to keep things alive
      sleep 20
    end

  end
end
