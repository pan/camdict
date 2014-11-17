require 'minitest/autorun'
require 'camdict'

module Camdict
  # this word has two derived words
  PLAGIARIZE = '<h2 class="di-title cdo-section-title-hw">plagiarize</h2>' +
    '<span class="runon"><span class=runon-title" title="Derived word">' +
      '<span class="w">plagiarism</span></span>' +
    '<span class="runon-info"><span class="posgram"><span class="pos">noun' +
    '</span></span></span></span>' +
   '<span class="runon"><span class=runon-title" title="Derived word">' +
      '<span class="w">plagiarist</span></span>'+
    '<span class="runon-info"><span class="posgram"><span class="pos">noun' +
    '</span></span></span></span>'

  class DefinitionTest < Minitest::Test

    def test_pos
      html = '<h2 class="di-title cdo-section-title-hw">favourite</h2>' +
        '<span class="di-info"><span class="posgram">' + 
        '<span class="pos" title="A word that ...">noun</span></span>' +
        '<span class="spellvar"><span class="v" title="Variant form">' +
        'favorite</span></span></span>'
      w = Camdict::Definition.new("favourite", :favourite=>html)
      assert_equal "noun", w.send(:pos)
      w = Camdict::Definition.new("favorite",  :favourite=>html)
      assert_equal "noun", w.send(:pos)
      html = '<h2 class="di-title cdo-section-title-hw">look at sth</h2>' +
        '<span class="di-info"><span class="anc-info-head"><span class="pos"' +
        ' title="Verb with an adverb...">phrasal verb</span><span class='+
        '"posgram">' +
        '<span class="pos" title="Verb with an adverb...">verb</span></span>'
      w = Camdict::Definition.new("look at sth","look-at-sth_1" => html)
      assert_equal "phrasal verb", w.send(:pos) 
      w = Camdict::Definition.new("plagiarist",:plagiarize => PLAGIARIZE)
      assert_equal "noun", w.send(:pos)
      htmli = '<h2 class="di-title cdo-section-title-hw">pass water</h2>' +
        '<div class="di-body"><div class="idiom-block">' +
        '<span class="idiom-body">'
      w = Camdict::Definition.new("pass water","pass-water" => htmli)
      assert_equal "idiom", w.send(:pos)
    end

    def test_title_word
      html = '<h2 class="di-title cdo-section-title-hw">aluminium</h2>'
      w = Camdict::Definition.new("aluminium",:aluminium=>html)
      assert_equal "aluminium", w.send(:title_word)
    end

    def test_derived_words
      w = Camdict::Definition.new("plagiarize",:plagiarize => PLAGIARIZE)
      r = w.send :derived_words 
      assert_equal %w(plagiarism plagiarist), r
      w = Camdict::Definition.new("mind", :mind=>"<h1>mind</h1>")
      assert ! (w.send :derived_words) 
    end

    def test_where?
      w = Camdict::Definition.new("plagiarize",:plagiarize => PLAGIARIZE)
      assert_equal "title", w.send(:where?)
      w = Camdict::Definition.new("plagiarism",:plagiarize => PLAGIARIZE)
      assert_equal "derived", w.send(:where?)
      html = '<h2 class="di-title cdo-section-title-hw">knock around/about'
      w = Camdict::Definition.new("knock about","knock-around-about"=>html) 
      assert_equal "title", w.send(:where?)
      w = Camdict::Definition.new("knock around","knock-around-about"=>html) 
      assert_equal "title", w.send(:where?)
    end

    def test_get_head_variant
      html = '<h2 class="di-title cdo-section-title-hw">aluminium</h2>' +
        '<span class="di-info"><span class="var"><span class="v" ' + 
        'title="Variant form">aluminum</span></span>'
      w = Camdict::Definition.new("aluminum",:aluminium=>html)
      assert_equal "aluminum", w.send(:get_head_variant).first
    end

    def test_spell_variant
      html = '<span class="spellvar">'+
        '<h2 class="di-title cdo-section-title-hw">aluminium</h2>' +
        '<span class="v" title="Variant form">aluminum</span></span>'
      w = Camdict::Definition.new("aluminum",:aluminium=>html)
      assert_equal "aluminum", w.send(:spell_variant)
    end

    def test_get_phrase
      phrase = %q(correct me if I'm wrong but...)
      html = '<h2 class="di-title cdo-section-title-hw">aluminium</h2>' +
        '<span class="phrase-block"><span class="phrase">' + phrase
      w = Camdict::Definition.new("correct me",:correct=>html)
      assert_equal [phrase], w.send(:get_phrase)
    end

    def test_idiom_explanation
      word = 'have it out with sb'
      meaning = 'to talk to someone about something they have done that makes' +
        ' you angry, in order to try to solve the problem:'
      html = "<h2 class='di-title cdo-section-title-hw'>#{word}</h2>" +
        '<span class="idiom-block"><span class="idiom-body">'+
        "<span class='def-block'><span class='def'>#{meaning}"
      def1  = Camdict::Definition.new(word, "have-it-out-with-sb"=>html)
      assert def1.is_idiom
      assert_equal meaning, def1.explanations.first.meaning
      def2 = Camdict::Definition.new("have it out", "have-it-out-with-sb"=>html)
      assert_equal meaning, def2.explanations.first.meaning
    end

    def test_parse_ipa
      imagin = %w(26a 2c8 6d e6 64 292 2e 26a 2e 6e).map { |c| 
        c.to_i 16}.pack 'U*'
      a = %w(259).map { |c| c.to_i 16}.pack 'U'
      ry = %w(72 2e 69).map {|c| c.to_i 16}.pack 'U*'
      html = '<h2 class="di-title cdo-section-title-hw">imaginary</h2>' +
        "<span class='di-info'><span class='ipa'>#{imagin}<span class='sp'>" +
        "#{a}</span>#{ry}</span>"
      w = Camdict::Definition.new("imaginary",:imaginary=>html)
      node = Nokogiri::HTML(html).css(".ipa")
      ukipa = w.send :parse_ipa, node
      actual = {baseipa: ukipa[:baseipa], sindex: ukipa[:sindex]}
      expected = {baseipa: imagin+a+ry, sindex:[10,1]}
      assert_equal expected, actual
    end

    def test_join_ipa
      html = '<h2 class="di-title cdo-section-title-hw">understand</h2>'
      w = Camdict::Definition.new("understand",:understand=>html)
      # head-tail hyphen
      understand = { 
        :uk_utf8  => %w(2cc 28c 6e 2e 64 259 2c8 73 74 e6 6e 64),
        :us_utf8  => %w(2d 64 25a 2d),
        :expected => %w(2cc 28c 6e 2e 64 25a 2c8 73 74 e6 6e 64),
        :us_inx   => nil,
        :uk_inx   => nil,
        :spiexp   => nil 
      }
      imaginary = {
        :uk_utf8  => %w(26a 2c8 6d e6 64 292 2e 26a 2e 6e 259 72 2e 69),
        :us_utf8  => %w(2d 259 2e 6e 65 72 2d),
        :expected => %w(26a 2c8 6d e6 64 292 2e 259 2e 6e 65 72 2e 69),
        :us_inx   => nil,
        :uk_inx   => [10,1],
        :spiexp   => nil 
      }
      plagiarism = {
        :uk_utf8  => %w(2c8 70 6c 65 26a 2e 64 292 259 72 2e 61 26a 7a),
        :us_utf8  => %w(2d 64 292 259 72 2e 26a 2e 7a 259 6d),
        :expected => %w(2c8 70 6c 65 26a 2e 64 292 259 72 2e 26a 2e 7a 259 6d),
        :us_inx   => [3,1,9,1],
        :uk_inx   => [8,1],
        :spiexp   => [8,1,14,1]
      }
      # left hyphen
      plagiarize = {
        :uk_utf8  => %w(2c8 70 6c 65 26a 2e 64 292 259 72 2e 61 26a 7a),
        :us_utf8  => %w(2d 64 292 259 2e 72 61 26a 7a),
        :expected => %w(2c8 70 6c 65 26a 2e 64 292 259 2e 72 61 26a 7a),
        :us_inx   => nil,
        :uk_inx   => [8,1],
        :spiexp   => nil 
      }
      painting = {
        :uk_utf8  => %w(2c8 70 65 26a 6e 2e 74 26a 14b),
        :us_utf8  => %w(2d 74 32c 26a 14b),
        :expected => %w(2c8 70 65 26a 6e 2e 74 32c 26a 14b),
        :us_inx   => nil,
        :uk_inx   => nil,
        :spiexp   => nil 
      }
      dictionary = {
        :uk_utf8  => %w(2c8 64 26a 6b 2e 283 259 6e 2e 259 72 2e 69),
        :us_utf8  => %w(2d 65 72 2e 69),
        :expected => %w(2c8 64 26a 6b 2e 283 259 6e 2e 65 72 2e 69),
        :us_inx   => nil,
        :uk_inx   => [6,1, 9,1],
        :spiexp   => [6,1]
      }
      harmfulness = {
        :uk_utf8  => %w(2c8 68 251 2d0 6d 2e 66 259 6c),
        :us_utf8  => %w(2d 6e 259 73),
        :expected => %w(2c8 68 251 2d0 6d 2e 66 259 6c 6e 259 73),
        :us_inx   => nil,
        :uk_inx   => [7,1],
        :spiexp   => [7,1]
      }
      # right hyphen
      toxic = {
        :uk_utf8  => %w(2c8 74 252 6b 2e 73 26a 6b),
        :us_utf8  => %w(2c8 74 251 2d0 6b 2d),
        :expected => %w(2c8 74 251 2d0 6b 73 26a 6b),
        :us_inx   => nil,
        :uk_inx   => nil,
        :spiexp   => nil 
      }
      data = [understand, imaginary, plagiarize, plagiarism, painting, 
        harmfulness, toxic]
      data.each_with_index { |word, i|
        full  = word[:uk_utf8].map {|c| c.to_i 16}.pack 'U*'
        short = word[:us_utf8].map {|c| c.to_i 16}.pack 'U*'
        full_sp = { baseipa: full, sindex: word[:uk_inx]}
        short_sp = { baseipa: short, sindex: word[:us_inx]}
        us = w.send :join_ipa, full_sp, short_sp
        a = us[:baseipa].unpack 'U*'
        spind = us[:sindex]
        actual = a.map { |n| n.to_s 16 }
        assert_equal word[:expected], actual
        assert_equal word[:spiexp], spind
      }
    end

    def test_mix_spi
      html = '<h2 class="di-title cdo-section-title-hw">understand</h2>'
      w = Camdict::Definition.new("understand",:understand=>html)
      # an IPA is 12 letters long, 012345678901 -345-, 
      lsp = [2,1, 5,1, 9,2]
      lrange = 0..3
      csp = [ 3, 2 ]
      cn = 3
      rrang = 8..12
      expected = [2,1, 6,2, 9,2]
      actual = w.send :mix_spi,lsp, lrange, csp, cn, lsp, rrang
      assert_equal expected, actual
    end

    def test_get_pronunciation
      title = '<h2 class="di-title cdo-section-title-hw">understand</h2>'
      ogglink = 'http://cam.org/british/ukunder112.ogg'
      mp3link = 'http://cam.org/british/ukunder112.mp3'
      html = title + %q(<span class='di-info'><a class='pron-uk' ) + 
        "data-src-ogg='#{ogglink}' data-src-mp3='#{mp3link}' href='#'>"
      w = Camdict::Definition.new("understand",:understand=>html)
      pron = w.send :get_pronunciation
      assert_equal mp3link, pron.uk.mp3
      assert_equal ogglink, pron.uk.ogg
      assert_nil pron.us.mp3
      assert_equal mp3link, w.pronunciation.uk.mp3
    end

    def test_get_region
      belaughing = { 
        :word     => 'be laughing',
        :expected => 'UK',
        :piece    => ''
      }
      favorite = { 
        :word     => 'favorite',
        :expected => 'US',
        :piece    => "<span class='spellvar'><span class='region'>US</span>" +
          "<span class='v' title='Variant form'>favorite"
      }
      aluminum = { 
        :word     => 'aluminum',
        :expected => 'US',
        :piece    => "<span class='var'><span class='region'>US</span>" +
          "<span class='v' title='Variant form'>aluminum"
      }
      data = [belaughing, favorite, aluminum]
      data.each { |d|
        title = "<h2 class='di-title cdo-section-title-hw'>#{d[:word]}</h2>"
        html = title + %q(<span class='di-info'><a class='lab'><span class=) + 
          "'region'>UK</span><span class='usage'>informal</span>"
        w = Camdict::Definition.new(d[:word], d[:word]=>html+d[:piece])
        region = w.send :get_region
        assert_equal d[:expected], region
      }
    end

    def test_gc
      plagiarize = { 
        :word     => 'plagiarize',
        :expected => 'I or T',
        :piece    => ''
      }
      data = [plagiarize]
      data.each { |d|
        title = "<h2 class='di-title cdo-section-title-hw'>#{d[:word]}</h2>"
        html = title + %q(<span class='di-info'><span class='gcs'>) +
          "<span class='gc'>I</span> or <span class='gc'>T</span>"
        w = Camdict::Definition.new(d[:word], d[:word]=>html+d[:piece])
        actual = w.send :get_gc
        assert_equal d[:expected], actual
      }
    end

    def test_get_plural
      mouse = { 
        :word     => 'mouse',
        :expected => 'mice',
        :piece    => "<span class='inf'>mice</span>"
      }
      fish = { 
        :word     => 'fish',
        :expected => %w(fish fishes),
        :piece    => '<span class="inf">fish</span> or <span class="inf">fishes'
      }
      data = [mouse, fish]
      data.each { |d|
        title = "<h2 class='di-title cdo-section-title-hw'>#{d[:word]}</h2>"
        html = title + %q(<span class='di-info'><span class='inf-group' ) +
          "type='plural'>"
        w = Camdict::Definition.new(d[:word], d[:word]=>html+d[:piece])
        w.instance_eval { @part_of_speech = 'noun'}
        actual = w.send :get_plural
        assert_equal d[:expected], actual
      }
    end

    def test_guided_word
      d = { word: 'rubber', expected: 'SUBSTANCE'}
      title = "<h2 class='di-title cdo-section-title-hw'>#{d[:word]}</h2>"
      html = title + %q(<span class='di-info'><strong class='gw'>(SUBSTANCE))
      w = Camdict::Definition.new(d[:word], d[:word]=>html)
      actual = w.send :get_guided_word
      assert_equal d[:expected], actual
    end

    def test_get_irregular
      blow = { 
        :word     => 'blow',
        :expected => ['blew','blown', nil],
        :piece    => "><span class='inf'>blew</span></span>,<span class='inf-" +
          "group'><span class='inf'>blown</span></span>"
      }
      bet = { 
        :word     => 'bet',
        :expected => %w(bet bet betting),
        :piece    => 'type="pres_part"><span class="inf">betting</span>' +
          '</span><span class="inf-group" type="past"><span class="inf">bet'
      }
      data = [blow, bet]
      data.each { |d|
        title = "<h2 class='di-title cdo-section-title-hw'>#{d[:word]}</h2>"
        html = title + %q(<span class='di-info'><span class='inf-group' )
        w = Camdict::Definition.new(d[:word], d[:word]=>html+d[:piece])
        expected = w.instance_eval { 
          @part_of_speech = 'verb'
          sp, pp, pr = d[:expected]
          Camdict::Definition::Irregular.new(sp, pp, pr)
        }
        actual = w.send :get_irregular
        assert_equal expected, actual
      }
    end

  end
end
