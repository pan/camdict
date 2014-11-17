require 'minitest/autorun'
require 'camdict'

module Camdict
  class ExplanationiTest < Minitest::Test
    def test_explanations
      w = Camdict::Word.new('correct')
      defa = w.definitions
      def1 = defa.first #first is adjective
      e1 = def1.explanations.first
      #todo: level info is not in english-chinese-simplied dictionary
      #assert_equal "A2", e1.level
      #assert_equal "B2", defa.last.explanations.first.level
      assert_equal "I've got thirty exam papers to correct.", 
        defa.last.explanations.first.examples.last.sentence
      w = Camdict::Word.new('correctly')
      defa = w.definitions
      def1 = defa.first #first is adjective
      e1 = def1.explanations
      assert_equal "Have I pronounced your name correctly?", 
        e1[2].examples[0].sentence
      #assert_equal "B1", e1[2].level
    end

    def test_phrase_meaning
      w = Camdict::Word.new('blow your nose')
      defa = w.definitions
      def1 = defa.first 
      el = def1.explanations.last
      exped = 'to force air from your lungs and through your nose to clear it'
      assert_equal exped, el.meaning
    end

  end
end
