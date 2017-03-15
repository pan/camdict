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
    def test_new
      c = Camdict::Client.new
      assert c.instance_eval { @dictionary == 'english' }
      c = Camdict::Client.new('english-chinese-simplified')
      assert_equal 'english-chinese-simplified', c.dictionary
    end

    def test_single_def?
      c = Camdict::Client.new
      html = '<div class="di-head"> <div class="di-title"> <h1 class="hw">'
      assert c.send :single_def?, Nokogiri::HTML(html)
      assert c.send :definition_page?, Nokogiri::HTML(html)
    end

    def test_entry_id
      c = Camdict::Client.new
      url = 'http://dictionary.cambridge.org/british/related'
      assert_equal 'related', c.send(:entry_id, url)
    end

    def test_matched_word?
      c = Camdict::Client.new
      html = '<li><span class="base"><b class="hw">related</b></span></li>'
      html1 = '<li><span class="base"><b class="hw">stress-related'
      html2 = '<span class="base">knock around/about'
      assert c.send :matched_word?, 'related', Nokogiri::HTML(html)
      assert !(c.send :matched_word?, 'related', Nokogiri::HTML(html1))
      assert c.send :matched_word?, 'knock around', Nokogiri::HTML(html2)
      assert c.send :matched_word?, 'knock about', Nokogiri::HTML(html2)
    end

    def test_mentry_links
      c = Camdict::Client.new
      rurl = 'http://dictionary.cambridge.org/dictionary/english'
      expected_result = "#{rurl}/related"
      result_list = Nokogiri::HTML(RESULTLIST)
      links = c.send(:mentry_links, 'related', result_list).first
      assert_equal expected_result, links
    end

    def test_di_head
      # Nokogiri version 1.6.2 and later required for this test case
      # but previous versions should also work with camdict
      # you won't see this test case failure once
      # https://github.com/sparklemotion/nokogiri/pull/1020 is released.
      c = Camdict::Client.new
      htmla = '<div data-tab="ds-british">'
      htmlb = '<h3 class="di-title cdo-section-title-hw">aluminium</h3>'\
              '<span class="pron-info"><span class="pos">noun</span></span>'
      result = c.send :di_head, Nokogiri::HTML(htmla + htmlb + '</div>')
      assert_equal(htmlb, result)
    end
  end
end
