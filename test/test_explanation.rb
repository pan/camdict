require 'minitest/autorun'
require 'camdict'

module Camdict
  class ExplanationTest < Minitest::Test

    def test_get_level
      html = '<span class="def-info"><span class="epp-xref B1">B1</span>'
      html = Nokogiri::HTML(html)
      exp  = Camdict::Explanation.new(html)
      assert_equal 'B1', (exp.send :get_level)
    end

    def test_get_meaning
      html = '<span class="def">in <a class="query" href="http://cambridge' +
        '.org/british">agreement </a>with the true facts or with what is ' +
        'generally accepted:'
      html = Nokogiri::HTML(html)
      exp  = Camdict::Explanation.new(html)
      expected = 
        'in agreement with the true facts or with what is generally accepted:'
      assert_equal expected, (exp.send :get_meaning)
    end

    def test_gc
      # rubber has region, usage, gc
      html = '<span class="def-info"><span class="gcs">U</span>'
      html = Nokogiri::HTML(html)
      exp  = Camdict::Explanation.new(html)
      assert_equal 'U', exp.gc
    end

    def test_get_sentence
      html = '<span class="eg">a correct answer</span>'
      html = Nokogiri::HTML(html)
      exp  = Camdict::Explanation::Sentence.new(html)
      assert_equal 'a correct answer', (exp.send :get_sentence)
    end

    def test_get_examples
      sent1 = %q(It's not correct to describe them as 'student')
      sent2 = %q("Your name is Angela Black?""That is correct.")
      html  = "<span class='examp'><span class='eg'>#{sent1}</span></span>"
      html += "<span class='examp'><span class='eg'>#{sent2}</span>" +
        '<span class="usage">formal</span>'
      html = Nokogiri::HTML(html)
      exp  = Camdict::Explanation.new(html)
      expected = exp.send :get_examples
      e1, e2 = expected.flatten
      assert_equal sent1, e1.sentence
      assert_equal sent2, e2.sentence
      assert_equal "formal", e2.usage
    end

    def test_get_synonym
      html = '<span class="entry-xref" type="Synonym"><span class="x-h">right'
      html = Nokogiri::HTML(html)
      exp  = Camdict::Explanation.new(html)
      assert_equal "right", (exp.send :get_synonym)
    end

    def test_get_opposite
      html = 
        '<span class="entry-xref" type="Opposite"><span class="x-h">incorrect'
      html = Nokogiri::HTML(html)
      exp  = Camdict::Explanation.new(html)
      assert_equal "incorrect", (exp.send :get_opposite)
    end

  end
end
