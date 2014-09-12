require 'test/unit'
require 'camdict'

module Camdict
  RESULTLIST = <<EoHTM
<ul class="result-list">
   <li><a href="http://dictionary.cambridge.org/dictionary/british/related_1" title="Definition of related adjective (CONNECTED) in British English"><span class='arl1'><span class="base"><b class="hw">related</b></span> <span title="A word that describes a noun or pronoun." class="pos">adjective</span> <b class="gw" title="Guide word: helps you find the right meaning when a word has more than one meaning">(CONNECTED)</b></span></a></li>
   <li><a href="http://dictionary.cambridge.org/dictionary/british/related_2" title="Definition of related adjective (FAMILY) in British English"><span class='arl1'><span class="base"><b class="hw">related</b></span> <span title="A word that describes a noun or pronoun." class="pos">adjective</span> <b class="gw" title="Guide word: helps you find the right meaning when a word has more than one meaning">(FAMILY)</b></span></a></li>
   <li><a href="http://dictionary.cambridge.org/dictionary/british/stress-related" title="Definition of stress-related adjective in British English"><span class='arl2'><span class="base"><b class="hw">stress-related</b></span> <span title="A word that describes a noun or pronoun." class="pos">adjective</span></span></a></li>
</ul>
EoHTM

  class ClientTest < Test::Unit::TestCase

    def test_new
      c = Camdict::Client.new
      assert c.instance_eval { @dictionary == "british" }
      c = Camdict::Client.new("american-english")
      assert c.instance_eval { @dictionary == "american-english" }
    end

    def test_single_def?
      c = Camdict::Client.new
      html = '<div class="di-head"> <div class="di-title"> <h1 class="hw">'
      assert c.send :single_def?, Nokogiri::HTML(html)
      assert c.send :definition_page?, Nokogiri::HTML(html)
    end
    
    def test_entry_id
      c = Camdict::Client.new
      url = "http://dictionary.cambridge.org/british/related_1"
      assert_equal "related_1", c.send( :entry_id, url)
    end

    def test_matched_word?
      c = Camdict::Client.new
      html = %q(<li><span class="base"><b class="hw">related</b></span></li>)
      html1 = %q(<li><span class="base"><b class="hw">stress-related)
      html2 = %q(<span class="base">knock around/about)
      assert  (c.send :matched_word?, "related", Nokogiri::HTML(html))
      assert !(c.send :matched_word?, "related", Nokogiri::HTML(html1))
      assert  (c.send :matched_word?, "knock around", Nokogiri::HTML(html2))
      assert  (c.send :matched_word?, "knock about", Nokogiri::HTML(html2))
    end

    def test_mentry_links
      c = Camdict::Client.new
      rurl = "http://dictionary.cambridge.org/dictionary/british/"
      expected_result = %w(related_1 related_2).map { |r|
        rurl + r
      }
      result_list = Nokogiri::HTML(RESULTLIST)
      links = c.send(:mentry_links, "related", result_list)
      assert expected_result == links
    end

    def test_di_head
      # Nokogiri version 1.6.2 and later required for this test case
      # but previous versions should also work with camdict
      # you won't see this test case failure once 
      # https://github.com/sparklemotion/nokogiri/pull/1020 is released.
      c = Camdict::Client.new
      htmla = %q(<div class="di-head">)
      htmlb = '<h2 class="di-title cdo-section-title-hw">aluminium</h2>' +
        '<span class="di-info"><span class="pos">noun</span></span>'
      result = c.send :di_head, Nokogiri::HTML(htmla+htmlb)
      assert_equal(htmlb, result)
    end

  end

end
