module Camdict
  module Common

    # Extend String class.
    String.class_eval do
      # 'blow a kiss to/at sb'.flatten =>
      # %q(blow a kiss to sb, blow a kiss at sb)
      # if it doesn't include a slash, returns stripped string
      def flatten
        str = self.strip
        # remove the space surrounding '/'
        str = str.gsub /\s*\/\s*/, '/'
        return str unless str.include? '/'
        len = str.length
        ret = []
        # when two strings are passed in separated with ';', then separate them
        if pos = str.index(';')
          ret += str[0..pos-1].flatten
          ret += str[pos+1..len-1].flatten
          return ret
        end
        # when a string has round brackets meaning optional part
        if str.include? '('
          head, bracket, tail = str.partition(/\(.*\)/)
          unless bracket.empty?
            ret << (head.strip + tail).flatten
            result = bracket.delete("()").flatten
            result = [result] if result.is_a? String
            result.each { |s|
              ret << (head + s + tail).flatten
            }
          end
          return ret.flatten
        end
        j=0     # count of the alternative words, 'to/at' has two.
        b=[]    # b[]/e[] index of the beginning/end of alternative words
        e=[]
        # set this flag when next word is expected an alternate word after slash
        include_next = false 
        for i in 0..len-1
          c = str[i] 
          case c
          # valid char in a word
          when /[[:alnum:]\-']/
            if b[j].nil?
              b[j] = i
              e[j] = i
            else
              e[j] = i
            end
          # char means a word has ended
          when " ", "!", "?", ",", "."
            if include_next
              break
            else
              b[j] = nil
              e[j] = nil
            end
          # 'or' separator
          when "/"
            j += 1
            include_next = true
          else
            raise NotImplementedError, "char '#{c}' found in '#{self}'."
          end
        end
        if j > 0
          for i in (0..j)
            # alternative word is not the last word and not at the beginning
            if (e[j]+1 < len) && (b[0] > 0)
              ret << str[0..b[0]-1] + str[b[i]..e[i]] + str[e[j]+1..len-1]
            elsif (e[j]+1 == len) && (b[0] > 0)
              ret << str[0..b[0]-1] + str[b[i]..e[i]]
            elsif (e[j]+1 < len) && (b[0] == 0)
              ret << str[b[i]..e[i]] + str[e[j]+1..len-1]
            else
              ret << str[b[i]..e[i]]
            end
          end 
        end
        ret
      end

      # Test whether a String includes the +word+. It's useful while testing 
      # a variable which might be an array of phrase or just a single phrase.
      def has?(word)
        self.include? word
      end
    end

    # Extend Array class.
    Array.class_eval do
      # Expand a phrase array into a flattened one. Example, 
      #   ['blow your nose', 'blow a kiss to/at sb'] #=>
      #   ['blow your nose', 'blow a kiss to sb', 'blow a kiss at sb']
      def expand
        ret = self.map { |p|
          p.flatten if p.is_a? String
        }
        ret.flatten
      end


      # Test if a phrase array includes a +word+.
      #   ['blow your nose', 'blow a kiss to/at sb'].has?("a kiss at") #=>true
      def has?(word)
        self.expand.each { |phr|
          return true if phr.include? word
        }
        false
      end

      # Iterate an array and return two elements +a+ +b+ each time for handling.
      def each_pair
        len = self.length
        i = 0
        while (i < len)
          a = self.at(i)
          b = self.at(i+1)
          yield(a, b)
          i += 2
        end
      end
    end

    private
    # Get the text selected by the css +selector+.
    def css_text(selector)
      node = @html.css(selector)
      node.text unless node.empty?
    end

    # Get sth by the css +selector+ for the derived word inside its runon node 
    def derived_css(selector)
      runon = @html.css(".runon")
      runon.each { |r|
        n = r.css('[title="Derived word"]')
        if n.text == @word 
          node = r.css(selector)
          yield(node)
        end
      }
    end

    # Get sth by the css +selector+ for the phrase inside the node phrase-block
    def phrase_css(selector)
      phbs = @html.css(".phrase-block")
      phbs.each { |phb|
        nodes = phb.css('.phrase, .v[title="Variant form"]')
        nodes.each { |n|
          if n.text.flatten.has? @word
            node = phb.css(selector)
            yield(node)
            break
          end
        }
      }
    end

  end
end
