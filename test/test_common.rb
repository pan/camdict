require 'test/unit'
require 'camdict'

module Camdict
  class CommonTest < Test::Unit::TestCase
    include Camdict::Common

    def test_flatten
      str = "blow a kiss to/at sb"
      expected = ['blow a kiss to sb', 'blow a kiss at sb']
      assert_equal expected, str.flatten
      str = "blow/blew a kiss"
      expected = ['blow a kiss', 'blew a kiss']
      assert_equal expected, str.flatten
      str = "knock around/about"
      expected = ['knock around', 'knock about']
      assert_equal expected, str.flatten
      str = "not give/budge/move an inch"
      expected = ['not give an inch', 'not budge an inch', 'not move an inch']
      assert_equal expected, str.flatten
      str = "fall into the/sb's trap"
      expected = ['fall into the trap', 'fall into sb\'s trap']
      assert_equal expected, str.flatten
      str = "what is sb/sth?"
      expected = ['what is sb?', 'what is sth?']
      assert_equal expected, str.flatten
      str = "look lively/sharp!"
      expected = ['look lively!', 'look sharp!']
      assert_equal expected, str.flatten
      str = "the like of sb/sth; sb's/sth's like"
      expected = ['the like of sb', 'the like of sth', 
        "sb's like", "sth's like"]
      assert_equal expected, str.flatten
      str = "go (like/down) a bomb"
      expected = ['go a bomb', 'go like a bomb', 'go down a bomb']
      assert_equal expected, str.flatten
      # need more examples to support complex 'or' separators 
      #   sound like/as if/as though
      #   look on/upon sb/sth as sth
      #   look at/see sth through rose-coloured/tinted glasses
    end

    def test_expand
      phra = ['blow your nose', 'blow a kiss to/at sb']
      expected = ['blow your nose', 'blow a kiss to sb', 'blow a kiss at sb']
      assert_equal expected, phra.expand
    end

    def test_has?
      phra = ['blow your nose', 'blow a kiss to/at sb']
      assert phra.has? "blow your nose"
      assert phra.has? "blow a kiss to sb"
      assert phra.has? "a kiss to sb"
      assert phra.has? "kiss at sb"
      assert "blow your nose".has?('nose')
      assert ! phra[1].flatten.has?(phra[0])
    end

    def test_phrase_css
      meaning = 'to have problems or be in difficult situation:'
      sentence = 'a ship is in difficluties off the coast of Ireland.'
      html = '<span class="phrase-block">' +
        '<span class="phrase">be in difficulties</span>' +
        '<span class="v" title="Variant form">be in difficulty</span>' +
        '<span class="phrase-body">' +
          "<span class='def-block'><span class='def'>#{meaning}</span>" +
            "<span class='examp'><span class='eg'>#{sentence}</span></span>"
      @html = Nokogiri::HTML html
      @word = 'be in difficulty'
      ret = ''
      phrase_css(".def-block") { |node|
        ret = Camdict::Explanation.new(node)
      }
      assert_equal sentence, ret.examples.first.sentence
      assert_equal meaning, ret.meaning
    end

  end
end
