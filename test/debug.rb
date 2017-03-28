require_relative 'helper'

module Camdict
  # test in a way that how camdict is working, so that remote changes can
  # be found quickly, especially for css class changes.
  class Debug < Minitest::Test
    def setup
      @word = ARGV[0]
      check_input
      @wordict = Camdict::Word.new(@word)
      @client = Camdict::Client.new
      $cache ||= {}
    end

    def test_search
      assert @client.send :fetch, @word
    end

    def test_word_page
      assert @client.send :single_def?, word_page
    end

    def test_british_tab
    end

    def test_where
      where = definations.send(:where, word_content)
      print 'where=', where
      refute_equal 'unknown', where
    end

    def test_ipa
      definations
    end

    def test_print
      puts
      @wordict.print
    end

    private

    def check_input
      @word || abort('please specify a word on command line')
    end

    def definations
      $cache[:definitions] ||=
        Camdict::Definition.new(@word).parse(word_content)
    end

    def word_content
      $cache[:word_content] ||= @client.send(:di_extracted, word_page)
    end

    def word_page
      $cache[:word_page] ||= @client.get_html(@client.word_url(@word))
    end
  end
end
