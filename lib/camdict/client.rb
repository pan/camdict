# frozen_string_literal: true
require 'camdict/http_client'
require 'camdict/string_ext'
require 'camdict/exception'

module Camdict
  # The client downloads all the useful data about a word or phrase from
  # remote Cambridge dictionaries, but not includes the extended data.
  # For example,
  # when the word "mind" is searched, the exactly matched entry is downloaded.
  # However, other related entries like "turn of mind" & "open mind"
  # are not included.
  class Client < HTTP::Client
    attr_reader :dictionary
    # Default dictionary is British english.
    # Other possible +dict+ values:
    # english-chinese-simplified, learner-english,
    # essential-british-english, essential-american-english, etc.
    def initialize(dict = nil)
      @dictionary = dict || 'english'
    end

    # Get a word's html definition from the web dictionary.
    # The returned result could be an empty string when nothing is found, or
    # its html definition
    def html_definition(word)
      html = fetch(word)
      if html
        di_extracted(html)
      else
        search(word)
      end
    end

    # Get a word html definition page by its entry +url+.
    def get_htmldef(url)
      di_extracted get_html(url)
    end

    # search a word with this URL
    def search_url(word)
      "#{host}/search/#{@dictionary}/?q=#{word}"
    end

    def word_url(word)
      "#{host}/dictionary/#{@dictionary}/#{encode(word).downcase}"
    end

    private

    def search(word)
      html = try_search(word)
      return '' unless html
      # some words return their only definition directly, such as plagiarism.
      if single_def?(html)
        di_extracted(html)
      else
        multiple_entries(word, html).join
      end
    end

    def host
      'http://dictionary.cambridge.org'
    end

    # returned page could be a spelling check suggestion page in case it is
    # not found, or the found page with all matched entries and related.
    # when entry urls are not found, they are empty and spelling suggestion
    # pages. It returns all the exactly matched entry links otherwise, raise
    # exception WordNotFound.
    def multiple_entries(word, html)
      html_defs = []
      mentry_links(word, html).each do |url|
        html_content = get_htmldef(url)
        html_defs << html_content if html_content
      end
      raise WordNotFound, "#{word} not found" if html_defs.empty?
      html_defs
    end

    def try_search(word)
      get_html(search_url(word))
    rescue OpenURI::HTTPError => e
      # When a word does not match any definitions, it returns 404 not found.
      return if e.message[0..2] == '404'
    end

    # Fetch word searching result page.
    # Returned result is either just a single definition page if there is only
    # one entry, or a result page listing all possible entries, or spelling
    # check result. All results are objects of Nokogiri::HTML.
    def fetch(w)
      ret = get_html(word_url(w))
      ret if definition_page? ret
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
      nodes.each { |a| links << a['href'] if matched_word?(word, a) }
      links
    end

    # Extract definition head and body from Nokogiri::HTML, discard share links
    def di_extracted(html)
      body = di_body(html)
      # searching aluminium returns an American or British english page
      # saparately, below condition filter out American english result
      return if body.empty?
      body.css('.share').each { |s| body.delete s }
      body
    end

    # Return definition body in html source
    def di_body(html)
      html.css("#{tab_css} .di-body")
    end

    # the css selecting a tab
    def tab_css
      "[#{tab}]"
    end

    # the tab attributes according to dictionary name
    def tab
      case @dictionary
      when 'english'
        'data-tab="ds-british"'
      end
    end

    # get the last part of http://dictionary.cambridge.org/british/related_1
    def entry_id(url)
      url.split('/').last
    end

    # phrase with space and single quote has to be replaced with dash
    def encode(word)
      word.gsub(/[ ']/, '-')
    end

    alias definition_page? single_def?

    using Camdict::StringExt
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
      return false if li.empty?
      resword = li.size == 1 ? li.text : li[0].text
      if resword.include?('/') || resword.include?(';')
        resword.flatten.include?(word)
      else
        word == resword
      end
    end
  end
end
