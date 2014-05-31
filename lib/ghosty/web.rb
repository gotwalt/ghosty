require 'celluloid'
require 'rack'
require 'rack/static'
module Ghosty
  class Web
    include Celluloid

    def initialize(port = 3100)
      @port = port
    end

    def start
      path = File.expand_path('../../../assets', __FILE__)

      app = Rack::Static.new(NotFound.new, root: path, urls: [''], index: 'index.html')

      @server = Rack::Server.new({
        app: app,
        :Port => @port
      }).start
    end

    def shutdown
      @server.shutdown if @server.respond_to?(:shutdown)
    end

    class NotFound
      def call(env)
        [404, {'Content-Type' => 'text/plain'}, ['Not Found']]
      end
    end
  end
end
