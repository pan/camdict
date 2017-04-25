# frozen_string_literal: true
require 'minitest/autorun'
require 'camdict'

module Camdict
  RESULTLIST = <<EoHTM
<ul class="prefix-block">
   <li><a href="http://dictionary.cambridge.org/dictionary/english/related" title="related definition in English"><span class='arl1'><span class="base"><b class="hw">related</b></span></a></li>
   <li><a href="http://dictionary.cambridge.org/dictionary/english/relate" title="relate definition in English"><span class='arl1'><span class="base"><b class="hw">relate</b></span></a></li>
</ul>
EoHTM

  class ClientTest < MiniTest::Test
    def setup
      @client = Camdict::Client.new
    end

    def test_new
      assert @client.instance_eval { @dictionary == 'english' }
      c = Camdict::Client.new('english-chinese-simplified')
      assert_equal 'english-chinese-simplified', c.dictionary
    end

    def test_single_def?
      html = '<div class="di-head"> <div class="di-title"> <h1 class="hw">'
      assert @client.send :single_def?, Nokogiri::HTML(html)
      assert @client.send :definition_page?, Nokogiri::HTML(html)
    end

    def test_entry_id
      url = 'http://dictionary.cambridge.org/british/related'
      assert_equal 'related', @client.send(:entry_id, url)
    end

    def test_matched_word?
      html = '<li><span class="base"><b class="hw">related</b></span></li>'
      html1 = '<li><span class="base"><b class="hw">stress-related'
      html2 = '<span class="base">knock around/about'
      assert @client.send :matched_word?, 'related', Nokogiri::HTML(html)
      assert !(@client.send :matched_word?, 'related', Nokogiri::HTML(html1))
      assert @client.send :matched_word?, 'knock around', Nokogiri::HTML(html2)
      assert @client.send :matched_word?, 'knock about', Nokogiri::HTML(html2)
    end

    def test_mentry_links
      rurl = 'http://dictionary.cambridge.org/dictionary/english'
      expected_result = "#{rurl}/related"
      result_list = Nokogiri::HTML(RESULTLIST)
      links = @client.send(:mentry_links, 'related', result_list).first
      assert_equal expected_result, links
    end

    def test_di_body
      html = '<div data-tab="ds-british">' \
        '<div class="di-body"><div class="pos-header"/><div class="pos-body">'\
        '</div></div>'
      assert @client.send :di_body, Nokogiri::HTML(html)
    end

    def test_encode
      assert_equal 'time-zone', @client.send(:encode, 'time zone')
      assert_equal 'time-s-up', @client.send(:encode, "time's up")
    end
  end
end
