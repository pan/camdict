# frozen_string_literal: true
require_relative 'helper'
require 'camdict/array_ext'

module Camdict
  class ArrayExtTest < Minitest::Test
    using Camdict::ArrayExt

    def test_expand
      phra = ['blow your nose', 'blow a kiss to/at sb']
      expected = ['blow your nose', 'blow a kiss to sb', 'blow a kiss at sb']
      assert_equal expected, phra.expand
    end

    def test_has?
      phra = ['blow your nose', 'blow a kiss to/at sb']
      assert phra.has? 'blow your nose'
      assert phra.has? 'blow a kiss to sb'
      assert phra.has? 'a kiss to sb'
      assert phra.has? 'kiss at sb'
    end
  end
end
