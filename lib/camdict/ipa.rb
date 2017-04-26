# frozen_string_literal: true
module Camdict
  # IPA related methods shall be included in Camdict::Definition
  module IPA
    # Get the IPA
    attr_reader :ipa

    private

    # Struct IPA is Internaltional Phonetic Alphabet
    # +uk+: UK IPA;   +k+: the superscript index in the UK IPA.
    # +us+: US IPA;   +s+: the superscript index in the US IPA.
    IPA = Struct.new(:uk, :k, :us, :s)

    def get_ipa(html)
      case where(html)
      when 'title', 'spellvar'
        uk, uk_idx = ipa_idx(html, 'UK')
        us, us_idx = ipa_idx(html, 'US')
      when 'derived'
        uk, uk_idx = derived_ipa_idx(html, 'UK')
        us, us_idx = derived_ipa_idx(html, 'US')
      end
      @ipa = IPA.new(uk, uk_idx, us, us_idx)
    end

    def ipa_idx(html, region)
      parse_ipa html.css(ipa_selector(region)).first
    end

    def derived_ipa_idx(html, region)
      derived_css(html, ipa_selector(region)) { |node| return parse_ipa(node) }
    end

    def ipa_selector(region)
      %([pron-region="#{region}"] .ipa)
    end

    # Parse an ipa node to get the ipa string and its superscript index
    def parse_ipa(node)
      position = 0
      pindex = []
      node&.children&.each do |c|
        len = c.text.length
        pindex += [position, len] if c['class'] == 'sp'
        position += len
      end
      pindex = nil if pindex.empty?
      [node&.text, pindex]
    end
  end
end
