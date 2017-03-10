# frozen_string_literal: true
module Camdict
  # HTTP module
  module HTTP
    require 'open-uri'

    # A default user agent string for this http client. It can be customised.
    AGENT =
      'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:26.0) Gecko/20100101 Firefox/26.0'

    # HTTP Client class
    class Client
      # Download a html page from a remote site, and return a Nokogiri::HTML
      # +url+ will be escaped by this method, and default +agtstr+ is AGENT.
      def self.get_html(url, agtstr = AGENT)
        url = URI.escape(url)
        Nokogiri::HTML(open(url, 'User-Agent' => agtstr))
      end
    end
  end
end
