require 'minitest/autorun'
require 'camdict'

module Camdict
  class HTTPClientTest < Minitest::Test
    
    def test_get_html
      require 'webrick'

      server = WEBrick::HTTPServer.new(:Port=>0, :BindAddress=>"127.0.0.1", 
        :Logger=>WEBrick::Log.new(nil,WEBrick::BasicLog::FATAL))
      Thread.new {
        res = Proc.new { |r, q|
          q.body ="hello"
        }
        server.mount_proc '/hi', nil, &res
        server.start
      }
      Thread.new {
        url = "http://127.0.0.1:#{server.config[:Port]}/hi"
        page = Camdict::HTTP::Client.get_html(url)
        server.stop 
        assert_equal "hello", page.text
      }.join
    end

  end
end
