require 'thor'
require 'ghosty/web'
require 'ghosty/player'

module Ghosty
  class Cli < Thor

    desc 'start', 'Runs the service'
    def start

      port = 3100
      assets_directory = 'assets'


      web = Ghosty::Web.new(assets_directory, port)
      web.async.start


      base_uri = "http://#{IPSocket.getaddress(Socket.gethostname)}:#{port}"



      sleep 2


      player = Ghosty::Player.new(base_uri, assets_directory)

      puts 'Playing'
      player.perform

      sleep
    end

  end
end
