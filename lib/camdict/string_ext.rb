# frozen_string_literal: true
module Camdict
  # Extention: Refine String class.
  module StringExt
    refine String do
      # Test whether a String includes the +word+. It's useful while testing
      # a variable which might be an array of phrase or just a single phrase.
      alias_method :has?, :include?

      # 'blow a kiss to/at sb'.flatten =>
      #   ['blow a kiss to sb', 'blow a kiss at sb']
      # if it doesn't include a slash, returns stripped string
      def flatten
        # strip & remove the space surrounding '/'
        str = strip.gsub(%r{\s*\/\s*}, '/')
        return str unless str.include? '/'
        return f_semicolon(str) if str.include?(';')
        return f_parenthese(str) if str.include? '('
        f_convert(str)
      end

      private

      # when two strings are passed in separated with ';', then separate them
      def f_semicolon(str)
        # workaround to bug or upgrade ruby to 2.4
        # str.split(';').map(&:flatten).flatten
        str.split(';').map { |s| s.flatten }.flatten
      end

      # when a string has round brackets meaning optional part
      def f_parenthese(str)
        head, bracket, tail = str.partition(/\(.*\)/)
        return if bracket.empty?
        ret = []
        ret << (head.strip + tail).flatten
        ret += f_str_in_bracket(bracket).map { |s| (head + s + tail).flatten }
        ret.flatten
      end

      def f_str_in_bracket(bracket)
        result = bracket.delete('()').flatten
        result.is_a?(String) ? [result] : result
      end

      def f_convert(str)
        b, e, j = f_alernative_index(str)
        return unless j.positive?
        f_combine(str, b, e, j)
      end

      def f_combine(str, b, e, j)
        (0..j).map do |i|
          if f_alter_not_start_end?(str, b, e, j)
            f_word_not_start_end(str, b, e, i, j)
          elsif f_alter_at_end?(str, b, e, j)
            f_word_at_end(str, b, e, i)
          elsif f_alter_at_start?(str, b, e, j)
            f_word_at_start(str, b, e, i, j)
          else str[b[i]..e[i]]
          end
        end
      end

      # alternative word is not the last word and not at the beginning
      def f_alter_not_start_end?(str, b, e, j)
        e[j] + 1 < str.length && b[0].positive?
      end

      def f_alter_at_end?(str, b, e, j)
        e[j] + 1 == str.length && b[0].positive?
      end

      def f_alter_at_start?(str, b, e, j)
        e[j] + 1 < str.length && b[0].zero?
      end

      def f_word_not_start_end(str, b, e, i, j)
        str[0..b[0] - 1] + str[b[i]..e[i]] + str[e[j] + 1..str.length - 1]
      end

      def f_word_at_end(str, b, e, i)
        str[0..b[0] - 1] + str[b[i]..e[i]]
      end

      def f_word_at_start(str, b, e, i, j)
        str[b[i]..e[i]] + str[e[j] + 1..str.length - 1]
      end

      def f_alernative_index(str)
        h = f_init
        f_alternative_loop(str, h)
        [h[:b], h[:e], h[:j]]
      end

      def f_alternative_loop(str, h)
        while h[:i] < str.length && !h[:quit]
          case str[h[:i]]
          # valid char in a word
          when /[[:alnum:]\-']/ then f_update_start_end(h)
          # char means a word has ended
          when ' ', '!', '?', ',', '.' then f_reset_or_quit(h)
          # 'or' separator
          when '/' then f_include_next(h)
          else f_raise_not_implement_error(str, h)
          end
          h[:i] += 1
        end
      end

      def f_init
        i = j = 0 # count of the alternative words, 'to/at' has two.
        b = [] # b[]/e[] index of the beginning/end of alternative words
        e = []
        # set this flag when next word is expected an alternate word after slash
        include_next = quit = false
        { i: i, j: j, b: b, e: e, include_next: include_next, quit: quit }
      end

      def f_include_next(h)
        h[:j] += 1
        h[:include_next] = true
      end

      def f_raise_not_implement_error(str, h)
        raise NotImplementedError, "char '#{str[h[:i]]}' found in '#{self}'."
      end

      def f_update_start_end(h)
        h[:b][h[:j]] = h[:i] if h[:b][h[:j]].nil?
        h[:e][h[:j]] = h[:i]
      end

      def f_reset_or_quit(h)
        return h[:quit] = true if h[:include_next]
        h[:b][h[:j]] = nil
        h[:e][h[:j]] = nil
      end
    end
  end
end
