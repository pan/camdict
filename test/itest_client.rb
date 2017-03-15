# frozen_string_literal: true
require 'minitest/autorun'
require 'camdict'

module Camdict
  class ClientiTest < Minitest::Test
    def setup
      @client = Camdict::Client.new
      @imaginary = 'http://dictionary.cambridge.org/dictionary/english/imaginary'
    end

    def test_fetch
      result = @client.send :fetch, 'pppppp'
      assert !result
    end

    def test_single_def?
      html = @client.get_html(@imaginary)
      assert @client.send :single_def?, html
    end

    def test_mentry_links
      related_html = @client.send :fetch, 'related'
      related_links = @client.send :mentry_links, 'related', related_html
      assert_equal 1, related_links.size
    end

    def test_matched_word?
      mind = "http://dictionary.cambridge.org/search/#{@client.dictionary}/"\
        '?q=mind'
      mind_node = @client.get_html(mind).css('.prefix-item').first
      assert @client.send :matched_word?, 'mind', mind_node
    end

    def test_di_head
      html = @client.get_html(@imaginary)
      r = @client.send :di_head, html
      assert_match(/cdo-section-title-hw/, r)
      assert_match(/pron-info/, r)
    end

    def test_di_body
      html = @client.get_html(@imaginary)
      r = @client.send :di_body, html
      assert_match(/sense-body/, r)
    end

    def test_html_definition
      search_result = @client.html_definition('related')
      key = search_result.first.keys.first
      assert_equal 'related', key
    end
  end
end
