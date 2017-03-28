# frozen_string_literal: true
require_relative 'helper'

module Camdict
  class DefinitioniTest < Minitest::Test
    def test_part_of_speech
      pos_data.each_pair do |word, exp_result|
        w = Camdict::Word.new(word)
        assert_equal exp_result, w.part_of_speech
      end
    end

    def test_pos
      w = Camdict::Word.new('correct')
      assert_equal %w(adjective verb), w.pos
    end

    def test_region_in_block
      skip 'word in block'
      w = Camdict::Word.new('rubbers')
      assert_equal 'US', w.region
    end

    def test_meaning
      skip 'phrase'
      w = Camdict::Word.new('pass water')
      expl = w.definition.senses.first.explanations.first
      assert_equal 'polite expression for urinate', expl.meaning
    end

    def pos_data
      # 'aluminum' => 'noun', US variant ought to be got from American tab
      { 'aluminium' => 'noun',
        'plagiarist' => 'noun',
        'ruby' => 'noun' }
      # adjective for ruby exists in British dictionary
    end
  end
end
