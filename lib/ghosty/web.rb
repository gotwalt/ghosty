require 'celluloid'
require 'rack'
require 'rack/static'
module Ghosty
  class Web
    include Celluloid

    def initialize(path, port = 3100)
      @port = port
      @path = path
    end

    def start
      app = Rack::Static.new(NotFound.new, root: @path, urls: [''], index: 'index.html')

      @server = Rack::Server.new({
        app: app,
        :Port => @port
      }).start
    end

    class NotFound
      def call(env)
        [404, {'Content-Type' => 'text/plain'}, ['Not Found']]
      end
    end
  end
end
