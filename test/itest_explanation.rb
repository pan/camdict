# frozen_string_literal: true
require_relative 'helper'

module Camdict
  class ExplanationiTest < Minitest::Test
    def test_level
      assert_equal 'B2', sense(:last).explanations.first.level
    end

    def test_sentence
      e = sense(:first).explanations.first
      assert_equal 'A2', e.level
      assert_equal %("Your name is Angela Black?" "That is correct."),
                   e.examples.last.sentence
    end

    def test_gc
      w = Camdict::Word.new('cause')
      def1 = w.definitions.first
      e1 = def1.senses.first.explanations.first
      assert_equal ' C or U ', e1.gc
    end

    def test_gc_usage
      w = Camdict::Word.new('cause')
      def1 = w.definitions.first
      e2 = def1.senses[2].explanations.first
      assert_equal ' + two objects ', e2.examples.last.usage
    end

    def test_correctly
      skip 'derived word - on the same page with its original'
      w = Camdict::Word.new('correctly').definition
      e1 = w.senses.first.explanations
      assert_equal 'Have I pronounced your name correctly?',
                   e1[2].examples[0].sentence
      assert_equal 'B1', e1[2].level
    end

    def test_phrase_meaning
      skip 'phrase ought have its own class'
      w = Camdict::Word.new('blow your nose')
      defa = w.definitions
      def1 = defa.first
      el = def1.explanations.last
      exped = 'to force air from your lungs and through your nose to clear it'
      assert_equal exped, el.meaning
    end

    private

    def sense(nth)
      Camdict::Word.new('correct').definition.senses.send(nth)
    end
  end
end
