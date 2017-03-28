# frozen_string_literal: true
require 'open-uri'

module Camdict
  # HTTP module
  module HTTP
    # A default user agent string for this http client. It can be customised.
    AGENT =
      'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:52.0) Gecko/20100101 Firefox/52'

    # HTTP Client class
    class Client
      # Download a html page from a remote site, and return a Nokogiri::HTML
      # +url+ will be escaped by this method, and default +agtstr+ is AGENT.
      def self.get_html(url, agtstr = AGENT)
        new.get_html(url, agtstr)
      end

      # see +self.get_html+
      def get_html(url, agtstr = AGENT)
        url = URI(url)
        Nokogiri::HTML(open(url, 'User-Agent' => agtstr))
      end
    end
  end
end
