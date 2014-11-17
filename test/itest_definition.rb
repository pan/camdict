require 'minitest/autorun'
require 'camdict'

module Camdict
  class DefinitioniTest < Minitest::Test

    def test_part_of_speech
      data = {'aluminium' => 'noun', 'aluminum' => 'noun', 
        'look at sth' => 'phrasal verb', 'plagiarist' => 'noun', 
        'pass water' => 'idiom', 'ruby' => 'noun'}
      # adjective for ruby exists in British dictionary
      data.each_pair { |word, exp_result|
        w = Camdict::Word.new(word)
        defa = w.definitions
        defo = defa.pop
        assert_equal exp_result, defo.part_of_speech
      }
      w = Camdict::Word.new('correct')
      defa = w.definitions
      assert_equal 'adjective', defa[0].part_of_speech 
      assert_equal 'verb', defa[1].part_of_speech 
    end

    def test_explanations
      w = Camdict::Word.new('pass water')
      defa = w.definitions
      expl = defa[0].explanations.first
      assert_equal "polite expression for urinate", expl.meaning
    end

    def test_ipa
      imaginary = {
        :word     => "imaginary",
        :uk_utf8  => %w(26a 2c8 6d e6 64 292 2e 26a 2e 6e 259 72 2e 69),
        :us_utf8  => %w(26a 2c8 6d e6 64 292 2e 259 2e 6e 65 72 2e 69),
        :uk_inx   => [10,1],
        :us_inx   => nil,
        :which    => 0
      }
      plagiarism = {
        :word     => "plagiarism",
        :uk_utf8  => %w(2c8 70 6c 65 26a 2e 64 292 259 72 2e 26a 2e 7a 259 6d),
        :us_utf8  => %w(2c8 70 6c 65 26a 2e 64 292 25a 2e 26a 2e 7a 259 6d),
        :uk_inx   => [8,1,14,1],
        :us_inx   => [13,1],
        :which    => 0
      }
      aluminum = {
        :word     => "aluminum",
        :uk_utf8  => %w(259 2c8 6c 75 2d0 2e 6d 26a 2e 6e 259 6d),
        :us_utf8  => %w(259 2c8 6c 75 2d0 2e 6d 26a 2e 6e 259 6d),
        :uk_inx   => nil,
        :us_inx   => nil,
        :which    => 0
      }
      sled = {
        :word     => "sled",
        :uk_utf8  => nil,
        :us_utf8  => nil,
        :uk_inx   => nil,
        :us_inx   => nil,
        :which    => 1
      }
      data = [imaginary, plagiarism, aluminum, sled]
      data.each { |d|
        w = Camdict::Word.new(d[:word])
        defa = w.definitions
        defo = defa[d[:which]]
        uk = defo.ipa.uk
        us = defo.ipa.us
        uk = uk.unpack('U*').map { |n| n.to_s 16 } if uk
        us = us.unpack('U*').map { |n| n.to_s 16 } if us
        actk = defo.ipa.k
        acts = defo.ipa.s
        assert_equal d[:uk_utf8], uk, "#{d[:word]} uk ipa got a problem"
        assert_equal d[:us_utf8], us, "#{d[:word]} us ipa got a problem"
        assert_equal d[:uk_inx], actk, "#{d[:word]} uk superscript index issue"
        assert_equal d[:us_inx], acts, "#{d[:word]} us superscript index issue"
      }
    end

    def test_region
      w = Camdict::Word.new('rubbers')
      defa = w.definitions
      actual = defa[0].region
      assert_equal "US", actual
    end
  
  end
end
