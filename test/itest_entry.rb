# frozen_string_literal: true
require_relative 'helper'

module Camdict
  class EntryiTest < Minitest::Test
    def setup
      fly_e = Camdict::Client.new.html_definition('fly')
                             .css('.entry-body__el').first
      @senses = Camdict::Definition.new('fly').send(:get_senses, fly_e)
    end

    def test_senses
      assert_equal 4, @senses.size
    end

    def test_meaning
      expect = 'When a bird, insect, or aircraft flies, it moves through ' \
        'the air: '
      assert_equal expect, @senses.first.explanations.first.meaning
    end

    def test_part_of_speech
      assert_equal 'verb', @senses.first.part_of_speech
    end

    def test_category
      assert_equal 'TRAVEL', @senses.first.category
    end

    def test_derived_pos
      html = Camdict::Client.new.html_definition('plagiarism')
                            .css('.entry-body__el')
      senses = Camdict::Definition.new('plagiarism').send(:get_senses, html)
      assert_equal 'noun', senses.first.part_of_speech
    end
  end
end
