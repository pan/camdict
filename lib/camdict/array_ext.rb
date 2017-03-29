# frozen_string_literal: true
require 'camdict/string_ext'

module Camdict
  # Extention: Refine Array class.
  module ArrayExt
    refine Array do
      # Iterate an array and return two elements +a+ +b+ each time for handling.
      def each_pair
        len = length
        i = 0
        while i < len
          a = at(i)
          b = at(i + 1)
          yield(a, b)
          i += 2
        end
      end

      # Test if a phrase array includes a +word+.
      #   ['blow your nose', 'blow a kiss to/at sb'].has?("a kiss at") #=> true
      def has?(word)
        expand.each { |phr| return true if phr.include? word }
        false
      end

      using Camdict::StringExt

      # Expand a phrase array into a flattened one. Example,
      #   ['blow your nose', 'blow a kiss to/at sb'] #=>
      #   ['blow your nose', 'blow a kiss to sb', 'blow a kiss at sb']
      def expand
        map { |p| p&.flatten || p }.flatten
      end
    end
  end
end
