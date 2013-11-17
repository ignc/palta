require "palta/core"
require "socket"
require "json"

module Palta

  class Server

    def initialize options = {}
      @host = options[:host] || "localhost"
      @port = options[:port] || 8888
      @debug = options[:debug] || options[:verbose] || false
      @dir = options[:dir] || "./.palta/data"
      @max_threads = options[:max_threads] || 8
      @threads = []
    end

    def actions &block
      instance_eval(&block) if block_given?
    end

    def on_msg msg
      send("on_#{msg[:type] || "default"}", msg)
    end

    def on_default msg
      puts "default: #{msg}"
    end

    def start
      @server = TCPServer.new @host, @port
      @max_threads.times do |i|
        @threads << Thread.new do
          loop do
            client = @server.accept
            data = client.recv(1024)
            if @debug
              puts "[Palta::Server] thread #{i} recv: #{data}"
            end
            msg = JSON.parse(data)
            on_msg(JSON.parse(msg, :symbolize_keys => true))
          end
        end
      end
    end

    def stop
      @threads.each do |t|
        Thread.kill(t)
      end
    end

  end

end
