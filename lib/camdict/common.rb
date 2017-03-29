# frozen_string_literal: true
require 'camdict/string_ext'

module Camdict
  # some common private methods used to extract Nokogiri nodes
  module Common
    private

    # Get the text selected by the css +selector+.
    def css_text(html, selector)
      node = html.css(selector)
      node.text unless node.empty?
    end

    # Get sth by the css +selector+ for the derived word inside its runon node
    def derived_css(html, selector)
      runon = html.css('.runon')
      runon.each do |r|
        n = r.css('[title="Derived word"]')
        if n.text == @word
          node = r.css(selector)
          yield(node)
        end
      end
    end

    using Camdict::StringExt

    # Get sth by the css +selector+ for the phrase inside the node phrase-block
    def phrase_css(html, selector)
      phbs = html.css('.phrase-block')
      phbs.each do |phb|
        nodes = phb.css('.phrase, .v[title="Variant form"]')
        nodes.each do |n|
          next unless n.text.flatten.has? @word
          node = phb.css(selector)
          yield(node)
          break
        end
      end
    end
  end
end
