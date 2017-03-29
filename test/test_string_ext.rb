# frozen_string_literal: true
require_relative 'helper'

module Camdict
  class StringExtTest < Minitest::Test
    using Camdict::StringExt

    def test_slash_in_middle
      str = 'blow a kiss to/at sb'
      expected = ['blow a kiss to sb', 'blow a kiss at sb']
      assert_equal expected, str.flatten
    end

    def test_slash_at_first
      str = 'blow/blew a kiss'
      expected = ['blow a kiss', 'blew a kiss']
      assert_equal expected, str.flatten
    end

    def test_slash_at_last
      str = 'knock around/about'
      expected = ['knock around', 'knock about']
      assert_equal expected, str.flatten
    end

    def test_two_middle_slashes
      str = 'not give/budge/move an inch'
      expected = ['not give an inch', 'not budge an inch', 'not move an inch']
      assert_equal expected, str.flatten
    end

    def test_single_quote
      str = "fall into the/sb's trap"
      expected = ['fall into the trap', 'fall into sb\'s trap']
      assert_equal expected, str.flatten
    end

    def test_question_mark
      str = 'what is sb/sth?'
      expected = ['what is sb?', 'what is sth?']
      assert_equal expected, str.flatten
    end

    def test_exlamation_mark
      str = 'look lively/sharp!'
      expected = ['look lively!', 'look sharp!']
      assert_equal expected, str.flatten
    end

    def test_semicolon
      str = "the like of sb/sth; sb's/sth's like"
      expected = ['the like of sb', 'the like of sth',
                  "sb's like", "sth's like"]
      assert_equal expected, str.flatten
    end

    def test_middle_parentheses
      str = 'go (like/down) a bomb'
      expected = ['go a bomb', 'go like a bomb', 'go down a bomb']
      assert_equal expected, str.flatten
    end

    def test_ending_parentheses
      str = 'the other side/end (of sth)'
      expected = ['the other side', 'the other end', 'the other side of sth',
                  'the other end of sth']
      assert_equal expected, str.flatten
    end

    def test_slash_means_non_alternative
      skip 'special cases for flatten'
      # strs = ['20/20 vision', 'public enemy number one/no. 1']
      # todo: still have uncovered special cases for flatten
      # "20/20 vision".flatten => "20/20 vision" no change expected
      # public enemy number one/no. 1 =>
      #   public enemy number one
      #   public enemy no. 1
      # need more examples to support complex 'or' separators
      #   sound like/as if/as though
      #   look on/upon sb/sth as sth
      #   look at/see sth through rose-coloured/tinted glasses
      #   give /quote sth/sb chapter and verse
    end

    def test_ellipsis
      str = 'the more...the more/less'
      expected = ['the more...the more', 'the more...the less']
      assert_equal expected, str.flatten
    end

    def test_has?
      assert 'blow your nose'.has?('nose')
    end
  end
end
