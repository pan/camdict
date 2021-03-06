# frozen_string_literal: true
require 'minitest/autorun'
require 'camdict'

module Camdict
  class HTTPClientTest < Minitest::Test
    def test_get_html
      require 'webrick'

      server = WEBrick::HTTPServer.new(
        Port: 0, BindAddress: '127.0.0.1',
        Logger: WEBrick::Log.new(nil, WEBrick::BasicLog::FATAL)
      )
      start_hello_thread(server)
      http_hello(server)
    end

    def test_self_get_html
      assert Camdict::HTTP::Client.respond_to? :get_html
      assert Camdict::HTTP::Client.new.respond_to? :get_html
    end

    def start_hello_thread(server)
      Thread.new do
        res = proc do |_r, q|
          q.body = 'hello'
        end
        server.mount_proc '/hi', nil, &res
        server.start
      end
    end

    def http_hello(server)
      Thread.new do
        url = "http://127.0.0.1:#{server.config[:Port]}/hi"
        page = Camdict::HTTP::Client.get_html(url)
        server.stop
        assert_equal 'hello', page.text
      end.join
    end
  end
end
