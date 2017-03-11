# frozen_string_literal: true
require 'camdict/http_client'

module Camdict
  # The client downloads all the useful data about a word or phrase from
  # remote Cambridge dictionaries, but not includes the extended data.
  # For example,
  # when the word "mind" is searched, the exactly matched entry is downloaded.
  # However, other related entries like "turn of mind" & "open mind"
  # are not included.
  class Client
    # Default dictionary is english.
    # Other possible +dict+ values:
    # english-chinese-simplified, learner-english,
    # essential-british-english, essential-american-english, etc.
    def initialize(dict = nil)
      @dictionary = dict || 'english'
    end

    # Get a word's html definition(s) by searching it from the web dictionary.
    # The returned result could be an empty array when nothing is found, or
    # is an array with a hash element,
    #   [{ word => html definition }],
    # or many hash elements when it has multiple entries(all combined probably,
    # so this case does not exist anymore)
    #   [{ entry_id => html definition }, ...].
    # Normally, when a +word+ has more than one meanings, its entry ID format is
    # like word_nn. Otherwise it's just the word itself.
    def html_definition(word)
      html = fetch(word)
      return [] if html.nil?
      # some words return their only definition directly, such as aluminium.
      if definition_page? html
        # entry id is just the word when there is only one definition
        { word => di_head_body(html) }
      else
        # returned page could be a spelling check suggestion page in case it is
        # not found, or the found page with all matched entries and related.
        # when entry urls are not found, they are empty and spelling suggestion
        # pages. So mentry_links() returns an empty array. Otherwise, it returns
        # all the exactly matched entry links.
        mentry_links(word, html).map do |url|
          { entry_id(url) => get_htmldef(url) }
        end
      end
    end

    # Get a word html page source by its entry +url+.
    def get_htmldef(url)
      html = Camdict::HTTP::Client.get_html(url)
      di_head_body(html)
    end

    private

    # Fetch word searching result page.
    # Returned result is either just a single definition page if there is only
    # one entry, or a result page listing all possible entries, or spelling
    # check result. All results are objects of Nokogiri::HTML.
    def fetch(w)
      # search a word with this URL
      search_url = "http://dictionary.cambridge.org/search/#{@dictionary}/?q="
      url = search_url + w
      Camdict::HTTP::Client.get_html(url)
    rescue OpenURI::HTTPError => e
      # "404" == e.message[0..2], When a word is not found, it returns 404
      # Not Found and spelling suggestions page.
    end

    # To determine whether or not the input object of Nokogiri::HTML is a page
    # of a word definition. Return true if it has a source structure like this,
    # <div class="di-head">
    #   <div class="di-title">
    #     <h1 class="hw">
    # This works for the translation page too, like English-Spanish.
    def single_def?(html)
      node = html.css('.di-head .di-title .hw')
      !node.empty?
    end

    # Find out matched entry links from search result page
    # <ul class="prefix-block">
    #   <li><a href="entry_link">
    # The search result html page should include above piece of code.
    # The extended links are filtered out and the matched word or phrase's
    # links are kept. An array of them are returned.
    # For example, when the searched word is "related", entry links are like,
    #   http://dictionary.cambridge.org/dictionary/english/related
    #   http://dictionary.cambridge.org/dictionary/english/relate
    #   ...
    # Returned result should only contain the first one.
    # Input html is an object of Nokogiri::HTML.
    def mentry_links(word, html)
      # suppose the word is not found in the dictionary, so it is empty.
      links = []
      nodes = html.css('.prefix-block a')
      # when found
      unless nodes.empty?
        nodes.each do |a|
          links << a['href'] if matched_word?(word, a)
        end
      end
      links
    end

    # Return true if the searched word matches the one on result page.
    # Node is an object of Nokogiri::Node
    # <li>
    #   <span class="base">
    #     <b class="phrase">out of mind, or
    #     <b class="hw">turn of mind, or
    #     <b class="w">mind-numbingly
    # Match criterion: the queried word should equal to the result word;
    #   the result phrase should be flattened, which should equal to the
    #   queried phrase.
    def matched_word?(word, node)
      li = node.css('.base')
      resword = li.size == 1 ? li.text : li[0].text
      if resword.include?('/') || resword.include?(';')
        resword.flatten.include?(word)
      else
        word == resword
      end
    end

    # Extract definition head and body from Nokogiri::HTML
    def di_head_body(html)
      di_head(html) + di_body(html)
    end

    # Return definition head in html source
    def di_head(html)
      html.css('.cdo-section-title-hw').to_html(save_with: 0) +
        html.css('.di-info').to_html(save_with: 0)
    end

    # Return definition body in html source
    def di_body(html)
      html.css('.di-body').to_html(save_with: 0)
    end

    # get the last part of http://dictionary.cambridge.org/british/related_1
    def entry_id(url)
      url.split('/').last
    end

    alias definition_page? single_def?
  end
end
