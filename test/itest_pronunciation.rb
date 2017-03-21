# frozen_string_literal: true
require_relative 'helper'

module Camdict
  class PronunciationiTest < Minitest::Test
    def test_uk_pronunciation
      pron = get_pron('understand')
      assert_equal uk_mp3, pron.uk.mp3
      assert_equal uk_ogg, pron.uk.ogg
    end

    def test_us_pronunciation
      pron = get_pron('understand')
      assert_equal us_mp3, pron.us.mp3
      assert_equal us_ogg, pron.us.ogg
    end

    def test_derived_uk
      pron = get_pron('harmfully')
      assert_equal harm_uk_mp3, pron.uk.mp3
      assert_equal harm_uk_ogg, pron.uk.ogg
    end

    def test_derived_us
      pron = get_pron('harmfully')
      assert_equal harm_us_mp3, pron.us.mp3
      assert_equal harm_us_ogg, pron.us.ogg
    end

    private

    def get_pron(word)
      defs = Camdict::Client.new.html_definition(word).first[word]
      d = Camdict::Definition.new(word)
      d.send :get_pronunciation, defs
    end

    def media
      'http://dictionary.cambridge.org/media/english/'
    end

    def uk_mp3
      media + 'uk_pron/u/uku/ukund/ukunder112.mp3'
    end

    def uk_ogg
      media + 'uk_pron_ogg/u/uku/ukund/ukunder112.ogg'
    end

    def us_mp3
      media + 'us_pron/u/und/under/understand.mp3'
    end

    def us_ogg
      media + 'us_pron_ogg/u/und/under/understand.ogg'
    end

    def harm_uk_mp3
      media + 'uk_pron/u/ukh/ukhar/ukhardw017.mp3'
    end

    def harm_uk_ogg
      media + 'uk_pron_ogg/u/ukh/ukhar/ukhardw017.ogg'
    end

    def harm_us_mp3
      media + 'us_pron/u/ush/ushan/ushangd027.mp3'
    end

    def harm_us_ogg
      media + 'us_pron_ogg/u/ush/ushan/ushangd027.ogg'
    end
  end
end
