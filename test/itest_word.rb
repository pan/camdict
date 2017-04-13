# frozen_string_literal: true
require_relative 'helper'

module Camdict
  class WordiTest < Minitest::Test
    def setup
      @film = Camdict::Word.new('film')
    end

    def test_definitions
      assert @film.definitions
    end

    def test_raw_definition
      refute @film.raw_definition.empty?
    end

    def test_ipa
      assert_equal 'fɪlm', @film.ipa
      assert_equal 'fɪlm', @film.ipa(:us)
    end

    def test_meaning
      m = 'a series of moving pictures, usually shown in a cinema or on' \
        ' television and often telling a story: '
      assert_equal m, @film.meaning
    end

    def test_meanings
      m = 'to record moving pictures with a camera, usually to make a film' \
        ' for television or the cinema: '
      assert_equal m, @film.meanings.last
      assert_equal 4, @film.meanings.size
    end

    def test_pronunciation
      uk_mp3 = 'http://dictionary.cambridge.org/media/english/uk_pron/u/ukf/' \
        'ukfil/ukfill_007.mp3'
      us_mp3 = 'http://dictionary.cambridge.org/media/english/us_pron/f/fil/' \
        'film_/film.mp3'
      assert_equal uk_mp3, @film.pronunciation
      assert_equal us_mp3, @film.pronunciation(:us)
    end

    def test_part_of_speech
      assert_equal %w(noun verb), @film.part_of_speech
    end
  end
end
