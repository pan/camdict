# frozen_string_literal: true
require 'minitest/autorun'
require 'camdict'

module Camdict
  class ClientiTest < Minitest::Test
    def setup
      @client = Camdict::Client.new
    end

    def test_fetch
      result = @client.send :fetch, 'pppppp'
      assert !result
    end

    def test_mentry_links
      related_html = @client.send :fetch, 'related'
      related_links = @client.send :mentry_links, 'related', related_html
      assert_equal 1, related_links.size
    end

    def test_html_definition
      search_result = @client.html_definition('related')
      key = search_result.first.keys.first
      assert_equal 'related', key
    end
  end
end
