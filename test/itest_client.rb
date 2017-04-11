# frozen_string_literal: true
require 'minitest/autorun'
require 'camdict'

module Camdict
  class ClientiTest < Minitest::Test
    def setup
      @client = Camdict::Client.new
      @imaginary = @client.word_url('imaginary')
    end

    def test_fetch
      assert !@client.send(:fetch, 'pppppp')
      assert @client.send(:fetch, 'mind')
    end

    def test_single_def?
      html = @client.get_html(@imaginary)
      assert @client.send :single_def?, html
    end

    def test_mentry_links
      related_html = @client.get_html(@client.search_url('related'))
      related_links = @client.send :mentry_links, 'related', related_html
      assert_equal 1, related_links.size
    end

    def test_matched_word?
      mind_url = @client.search_url('mind')
      mind_node = @client.get_html(mind_url).css('.prefix-item').first
      assert @client.send :matched_word?, 'mind', mind_node
    end

    def test_di_extracted
      html = @client.get_html(@imaginary)
      r = @client.send :di_extracted, html
      assert r.css('.cdo-section-title-hw')
      assert r.css('.pron-info')
    end

    def test_di_body
      html = @client.get_html(@imaginary)
      assert @client.send :di_body, html
    end

    def test_html_definition
      search_result = @client.html_definition('related')
      assert search_result.first
    end
  end
end
