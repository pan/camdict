# frozen_string_literal: true
module Camdict
  # pronunciation related methods shall be included in Camdict::Definition
  module Pronunciation
    # Struct Pronunciation has two members.
    # Each +uk+/+us+ has its own mp3/ogg links.
    Pronunciation = Struct.new(:uk, :us)
    # Struct Link has two members +mp3+ and +ogg+, which are the http links.
    Link = Struct.new(:mp3, :ogg)

    # Get the pronunciation
    attr_reader :pronunciation

    # Get the UK/US pronunciation mp3/ogg links as Struct uk:Link, us:Link
    def get_pronunciation(html)
      @pronunciation ||= parse_pron(html)
    end

    def parse_pron(html)
      case where(html)
      when 'title'
        ukpron = pronunciation_node(html, 'UK')
        uspron = pronunciation_node(html, 'US')
      when 'derived'
        ukpron = pronunciation_derived(html, 'UK')
        uspron = pronunciation_derived(html, 'US')
      end
      Pronunciation.new(link(ukpron), link(uspron))
    end

    def pronunciation_node(html, region)
      html.css(pronunciation_selector(region))
    end

    def pronunciation_derived(html, region)
      derived_css(html, pronunciation_selector(region)) { |node| return node }
    end

    def pronunciation_selector(region)
      %([pron-region="#{region}"] .sound)
    end

    # parameter +pron+ is a Nokigiri::Node
    def link(pron)
      return Link.new if pron.empty?
      mp3_link = pron.attr('data-src-mp3').text
      ogg_link = pron.attr('data-src-ogg').text
      Link.new mp3_link, ogg_link
    end
  end
end
