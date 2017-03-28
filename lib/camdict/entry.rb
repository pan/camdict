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

    # Return values: String, [String], nil
    # Irregular plural, like criteria
    def get_plural(html)
      return unless senses.any? { |s| s.part_of_speech.include? 'noun' }
      node = html.css(".pos-header .inf-group[type='plural'] .inf")
      return node.text if node.size < 2
      # fish has two
      node.map(&:text)
    end

    # Simple Past, Past Participle, PRsent participle of a verb. Only irregular
    # verbs have these values. Its struct memebers are +sp+, +pp+, +pr+.
    Irregular = Struct.new(:sp, :pp, :pr)

    # Return nil or Irregular struct
    def get_irregular(html)
      return unless senses.any? { |s| s.part_of_speech.include? 'verb' }
      present, sp, pp = explicit_irregular(html)
      if sp.nil? || sp.empty?
        node = html.css('.pos-header .inf') # arise
        sp, pp = node.map(&:text) if node.size.positive?
      end
      Irregular.new(sp, pp, present)
    end

    def explicit_irregular(html)
      [css_text(html, irregular_selector('pres_part')),
       css_text(html, irregular_selector('past_tense')),
       css_text(html, irregular_selector('past_part'))]
    end

    def irregular_selector(tense)
      ".pos-header .inf-group[type='#{tense}'] .inf"
    end
  end
end
