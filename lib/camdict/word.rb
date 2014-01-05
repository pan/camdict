require 'camdict/client'
require 'camdict/definition'

module Camdict
  # Get all definitions data about a word or phrase including IPAs, 
  # pronunciations, usage sentences, etc. from Camdict Client.
  class Word

    # New a +word+ or phrase, default +dictionary+ is british.
    def initialize(word, dictionary=nil)
      @word ||= word
      @dictionary = dictionary
      @raw_definitions = []   # each element is a hash
      @definitions = []       # each element is a Definition object
    end

    # Get all definitions for this word from remote online dictionary
    def definitions
      client = Camdict::Client.new(@dictionary)
      @raw_definitions = client.html_definition(@word)
      if found?
        @definitions = @raw_definitions.map { |r|
          Camdict::Definition.new(@word, r)
        }
      end
    end

    # Found in the diciontary? Return number of found entries
    def found?
      @raw_definitions.size
    end

    alias in? found?

  end
end
