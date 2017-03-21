# frozen_string_literal: true
require_relative 'helper'

module Camdict
  class IPAiTest < Minitest::Test
    def test_imaginary
      ipa_test(imaginary)
    end

    # derived word
    def test_plagiarism
      ipa_test(plagiarism)
    end

    def test_aluminum
      skip 'words are both in British & American dictionary, and on two pages'
      ipa_test(aluminum)
    end

    # two .headword
    def test_sled
      ipa_test(sled)
    end

    private

    def ipa_assert(e, a)
      uk, us, actk, acts = a
      assert_equal e[:uk_utf8], uk, "#{e[:word]} uk ipa got a problem"
      assert_equal e[:us_utf8], us, "#{e[:word]} us ipa got a problem"
      assert_equal e[:uk_inx], actk, "#{e[:word]} uk superscript index issue"
      assert_equal e[:us_inx], acts, "#{e[:word]} us superscript index issue"
    end

    def ipa_test(d)
      defi = definition(d)
      uk = ipa_hexs(defi, :uk)
      us = ipa_hexs(defi, :us)
      actual = [uk, us, defo.ipa.k, defo.ipa.s]
      ipa_assert(d, actual)
    end

    def definition(d)
      Camdict::Word.new(d[:word]).definitions.first
    end

    def ipa_hexs(defi, region)
      defi.ipa.send(region).unpack('U*').map { |n| n.to_s 16 }
    end

    def imaginary
      {
        word: 'imaginary',
        uk_utf8: %w(26a 2c8 6d e6 64 292 2e 26a 2e 6e 259 72 2e 69),
        us_utf8: %w(26a 2c8 6d e6 64 292 2e 259 2e 6e 65 72 2e 69),
        uk_inx: [10, 1],
        us_inx: nil
      }
    end

    def plagiarism
      {
        word: 'plagiarism',
        uk_utf8: %w(2c8 70 6c 65 26a 2e 64 292 259 72 2e 26a 2e 7a 259 6d),
        us_utf8: %w(2c8 70 6c 65 26a 2e 64 292 25a 2e 26a 2e 7a 259 6d),
        uk_inx: [8, 1, 14, 1],
        us_inx: [13, 1]
      }
    end

    def aluminum
      {
        word: 'aluminum',
        uk_utf8: %w(259 2c8 6c 75 2d0 2e 6d 26a 2e 6e 259 6d),
        us_utf8: %w(259 2c8 6c 75 2d0 2e 6d 26a 2e 6e 259 6d),
        uk_inx: nil,
        us_inx: nil
      }
    end

    def sled
      {
        word: 'sled',
        uk_utf8: %w(73 6c 65 64),
        us_utf8: %w(73 6c 65 64),
        uk_inx: nil,
        us_inx: nil
      }
    end
  end
end
