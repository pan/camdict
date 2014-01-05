require 'test/unit'
require 'camdict'

module Camdict
  class ClientiTest < Test::Unit::TestCase
    def test_fetch
      c = Camdict::Client.new
      result = c.send :fetch, "pppppp"
      assert ! result
    end

    def test_html_definition
      c = Camdict::Client.new
      search_result = c.html_definition("related")
      r = search_result.collect {|r| r.keys}
      assert_equal ["related_1", "related_2"], r.flatten
    end
  end
end

