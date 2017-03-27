# frozen_string_literal: true
require 'camdict/explanation'

module Camdict
  # definition entry, an entry contains all definitions for a part of speech.
  # parsing the entry to get meanings, example sentences
  module Entry
    Sense = Struct.new(:part_of_speech, :category, :explanations)

    def get_senses(html)
      pos = pos(html)
      html.css('.sense-block').map do |sb|
        Sense.new(pos, category(sb), explanations(sb))
      end
    end

    def category(html)
      html.css('.guideword span').text
    end

    # Get explanations inside a definition block
    def explanations(html)
      html.css('.def-block').map { |db| Camdict::Explanation.new(db) }
    end

    def pos(html)
      case where(html)
      when 'title', 'spellvar'
        html.css(pos_selector).first.text
      when 'derived'
        derived_css(html, pos_selector) { |node| return node.text }
      end
    end

    def pos_selector
      '.pos-header .pos'
    end
  end
end
