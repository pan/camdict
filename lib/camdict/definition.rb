require 'camdict/explanation'

module Camdict

  # Parse an html definition to get explanations, word, IPA, prounciation, 
  # part of speech, etc.

  class Definition
    # Struct IPA is the written pronunciations for UK/US.   
    # +uk+: the UK IPA;   +k+: the superscript index in UK IPA.  
    # +us+: the US IPA;   +s+: the superscript index in US IPA.
    IPA = Struct.new(:uk, :k, :us, :s)
    # Struct Pronunciation has two memebers. 
    # Each +uk+/+us+ has its own mp3/ogg links.
    Pronunciation = Struct.new(:uk, :us)  
    # Struct Link has two memembers +mp3+ and +ogg+, which are the http links.
    Link = Struct.new(:mp3, :ogg)

    # Simple Past, Past Participle, PRsent participle of a verb. Only irregular
    # verbs have these values. It struct memebers are +sp+, +pp+, +pr+.
    Irregular = Struct.new(:sp, :pp, :pr)
    # Get part of speech of a word or phrase.
    attr_reader :part_of_speech
    # Get explanations for this definition.
    attr_reader :explanations
    # Is the queried word/phrase an idiom?
    attr_reader :is_idiom
    # Get the IPA
    attr_reader :ipa
    # Get the pronunciation
    attr_reader :pronunciation
    # Get the region: UK or US
    attr_reader :region
    # Get the short usage 
    attr_reader :usage
    # Grammar code. Like U, means uncountable noun.
    attr_reader :gc
    # Get the guided word for this definition entry, which is usually just one
    # word or a phrase. This does not exist when there is only one definition.
    # It is useful when there are many definitions for one word to distinguish
    # them. 
    attr_reader :guided
    # Get the verb irregular form word. +word.verb.sp+ gets the simple past
    # tense of this verb.
    attr_reader :verb

    # Input +word+ and +entry_html+ are
    # { entry ID => its html definition source }
    def initialize(word, entry_html)
      @word = word
      @entry_id, @html = entry_html.flatten
      @html = Nokogiri::HTML(@html)
      @title_word = title_word           # String 
      @derived_words = derived_words     # String or [String]
      @spelling_variant = spell_variant  # String
      @head_variant = get_head_variant   # [String]
      @body_variant = get_body_variant   # [String]
      @inflection = get_inflection       # [String]
      @phrase = get_phrase               # [String]
      @is_idiom = is_idiom?              # True or False
      @part_of_speech = pos              # String or [String] or []
      @explanations = get_explanations   # [Camdict::Explanation]
      @ipa = get_ipa                     # Struct uk:String,us:String,k:[],s:[]
      @pronunciation = get_pronunciation # Struct uk:Link, us:Link
      @region = get_region               # String
      @usage = get_usage                 # String
      @gc = get_gc                       # String
      @plural = get_plural               # String or [String]
      @guided = get_guided_word          # String
      @verb = get_irregular              # Struct Irregular
    end

    private
    # Get the definition page title word, which is either a word or phrase. 
    # This is necessary because it doesn't always get the searched
    # word exactly. For instance, searching baldness gets bald. This is 
    # how the online dictionary is organised -- when words having 
    # the same root they often share the same explanations.
    # <h2 class="di-title cdo-section-title-hw">look at sth</h2>
    def title_word
      css_text ".di-title.cdo-section-title-hw"
    end

    # Some words have more than one derived words, like plagiarize has two.
    # Return an Array of derived words or nil when no derived word found
    # <span class=runon-title" title="Derived word">
    #   <span class="w">plagiarism
    def derived_words
      node = @html.css('[title="Derived word"]')
      node.map { |e| e.content } unless node.empty?
    end

    # Get the variant word or phrase inside di-info block but exclude those 
    # inside phrase-block or spelling variant, from where is part of the 
    # definition header.
    # Such as, US/UK variant, or hasing the same meaning, but
    # different pronunciation.
    # There are more than one variant for one entry, such as ruby, aluminium
    def get_head_variant
      # aluminium: aluminum, Al
      node = @html.css(".di-info .var .v[title='Variant form']")
      node.map { |n| n.text } unless node.empty?
    end

    # Body variant is inside the di-body block. This is useful to get their
    # part of speech, such as e-book.
    def get_body_variant
      css_text ".di-body .v[title='Variant form']"
    end

    # Get spelling variants, which have same pronunciations.
    def spell_variant
      # plagiarize: plagiarise
      css_text(".spellvar .v[title='Variant form']")
    end

    # Irregular plural, like criteria
    def get_inflection
      css_text ".di-info .inf"
    end

    # Get phrase and its variant which are not flattened yet 
    def get_phrase
      node = @html.css(".phrase, .phrase-info .v[title='Variant form']")
      node.map { |n| n.text } unless node.empty?
    end

    # Where are the searched word's part of speech, IPAs, prounciations
    # It could be found either at the position of "title" or "derived",
    # or "head_variant", "spellvar", "phrase", "idiom".
    # Other places are still "unknown".
    def where?
      location = "title" if @word == @title_word 
      unless @title_word.nil?
        location = "title" if @title_word.include?("/") && 
          @title_word.flatten.include?(@word)
      end
      location = "idiom" if @is_idiom && @title_word.include?(@word)
      unless @spelling_variant.nil?
        # spelling variant is treated as "title word"
        location = "spellvar" if @spelling_variant.include? @word
      end
      unless @head_variant.nil?
        location = "head_variant" if @head_variant.include? @word
      end
      location ="body_variant" if @body_variant && @body_variant.include?(@word)
      location = "inflection" if @inflection && @inflection.include?(@word)
      unless @derived_words.nil?
        if @derived_words.include? @word
          unless location.nil?
            #'ruby' has two locations title and derived
            location = [location, "derived"] 
          else
            location = "derived"
          end
        end
      end
      unless @phrase.nil?
        location = "phrase" if @phrase.has?(@word) && @word.include?(" ")
        # rubbers has no space, but it's treated as a phrase.
        location = "phrase" if @phrase.include? @word
      end
      location ||= "unknown"
    end
    
    # * When the searched word is a title word
    # <span class="di-info">
    # For noun, verb, adj, adv, pronoun, prep, conj, exclamation:
    #   <span class="posgram">
    #     <span class="pos" title="A word that ...">noun</span>
    # For phrasal verb:  reach out to sb
    #   <span class="anc-info-head"> 
    #     <span class="pos" title="Verb with an adverb ...">phrasal verb</span>
    #     ... same as above line ...                        verb ...
    # For idiom:  
    #   "curiosity killed the cat"
    #   <span class="lab" title="A short, well-know ...">
    #     <span class="usage" title="A short ...">saying</span>
    # or "can't get your head around sth"
    #     <span class="usage" title="A short ...">informal</span>
    # or "set/put the seal on sth" and many other idioms have no di-info, but 
    # all should have di-body idiom-block idiom-body
    # * When the searched word is a derived word
    #   <span class="runon">...<span class="runon-info">
    #     <span class="posgram"><span class="pos">noun
    # * When there are more than one part of speech on the same page, like,
    #   'ruby': adjective and noun are both returned.
    # * When the dictionary has no direct answer - unknown
    def pos
      pos_ret = []
      loc = where?
      loc = [loc] if loc.is_a? String
      loc.each { |loca|
        case loca
        when 'title', 'head_variant', 'body_variant', 'spellvar', 'inflection'
          # for phrasal verb
          node = @html.css(".anc-info-head > .pos")
          # center has two pos, noun,verb; centre: noun, adj.
          node = @html.css(".di-info .pos") if node.empty?
          pos_ret += node.map {|n| n.text} unless node.empty?
        when 'idiom'
          pos_ret << "idiom"
        when 'derived'
          derived_css(".runon-info .posgram .pos") { |node|
            pos_ret << node.text
          }
        when 'unknown'
          #"Unknown or don't have a part of speech"
        end
      }
      return pos_ret.pop if pos_ret.length == 1
      pos_ret
    end

    # Get explanations inside a definition block
    def get_explanations
      defblocks = @html.css(".sense-body > .def-block")
      exps = defblocks.map { |db| 
        Camdict::Explanation.new(db)
      }
      loc = where?
      loc = [loc] if loc.is_a? String
      loc.each { |loca|
        case loca
        when 'title', 'head_variant', 'spellvar', 'inflection'
          # Got it already
        when 'derived'
          derived_css(".def-block") { |node|
            exps << Camdict::Explanation.new(node)
          }
        when 'phrase'
          phrase_css(".def-block") { |node|
            exps << Camdict::Explanation.new(node)
          }
        when 'idiom'
          node = @html.css(".idiom-block .def-block")
          exps << Camdict::Explanation.new(node)
        end
      }
      exps
    end

    # Parse html and check whether there is idiom related block.
    def is_idiom?
      node = @html.css(".idiom-block .idiom-body")
      true unless node.empty?
    end

    # A word may has uk and us written pronouncation. Superscripts in an IPA
    # are stored in an array, k for UK, s for US. The returned IPA Struct likes,
    # uk: String, us:String, k:[position1, length1, position2, length2],
    # s: [position, length] 
    # Position is the superscript index in the IPA, and the next number length
    # is the length of this superscript.
    def get_ipa
      # UK is always the first one
      uknode = @html.at_css ".di-info .ipa"
      # phrase or idiom has no IPA
      return IPA.new if uknode.nil?
      ukbase = parse_ipa(uknode) 
      # in most cases they are same
      usbase = ukbase  
      loc = where?
      loc = [loc] if loc.is_a? String
      loc.each { |loca|
        case loca
        when 'title', 'spellvar'
          # US IPA is always followed by a symbol US
          # favorite: UK/US ipa (spellvar US s:favorite) => normal title word
          usnode = @html.css ".di-info img.ussymbol + .pron .ipa"
          usbase = parse_ipa(usnode) unless usnode.nil?
        when 'inflection'
          usnode = @html.css ".info-group img.ussymbol + .pron .ipa"
          usbase = parse_ipa(usnode) unless usnode.nil?
          ukinfnode = @html.css ".info-group .pron .ipa"
          ukinf = parse_ipa(ukinfnode) unless ukinfnode.nil?
          if usbase[:baseipa] && usbase[:baseipa].include?('-')
            usbase = join_ipa(ukbase, usbase) 
          end
          if ukinf[:baseipa] && ukinf[:baseipa].include?('-')
            ukbase = join_ipa(ukbase, ukinf) 
          end
        when 'head_variant'
          # variant word's IPA can be got from its definition page when it is a
          # title word, or from the bracket. Like, 
          # aluminium: UK ipa, (variant s:aluminum: US ipa) => in bracket
          # behove: UK ipa, US ipa (variant US s:behoove ipa) => in bracket
          # Many other variants have no IPA inside the bracket and title word's
          # IPA are not theirs.
          # eraser: UK ipa, US ipa US (variant UK s:rubber) => no IPA
          # plane: UK/US ipa (variant UK s:aeroplane, US s:airplane) => no IPA
          # aeroplane: UK ipa,US ipa (variant US s:airplane) => no IPA
          # ass: UK/US ipa, | variant UK s:arse => no IPA
          # sledge: UK ipa, (variant US s:sled) => no IPA
          # titbit: UK/US ipa, (variant US s:tidbit) => no IPA
          node = @html.css ".di-info .var .ipa"
          node.empty? ? (return IPA.new) : ukbase = usbase = parse_ipa(node)
          return IPA.new unless ukbase[:baseipa]
        when 'derived'
          derived_uk = nil
          derived_css('.ipa') { |node|
            derived_uk = parse_ipa(node.first) unless node.first.nil?
          }
          derived_css("img.ussymbol + .pron .ipa") { |node|
            usbase = parse_ipa(node) unless node.nil?
          }
          if derived_uk && derived_uk[:baseipa].include?('-')
            ukbase = join_ipa(ukbase, derived_uk)
          elsif derived_uk
            # uk base may come from the derived word, such as fermentation.
            ukbase = derived_uk
          end
        end
      }
      if usbase[:baseipa] && usbase[:baseipa].include?('-')
        usbase = join_ipa(ukbase, usbase) 
      end
      uk, k = ukbase[:baseipa], ukbase[:sindex]
      us, s = usbase[:baseipa], usbase[:sindex]
      IPA.new(uk, k, us, s)
    end

    # Parse an ipa node to get the ipa string and its superscript index
    def parse_ipa(node)
      position = 0
      pindex = []
      node.children.each { |c|
        len = c.text.length
        pindex += [position,len] if c["class"] == "sp"
        position += len
      }
      pindex = nil if pindex.empty?
      { baseipa: node.text, sindex: pindex }
    end
    
    # A short IPA begins with a hyphen, which shares a common beginning with the
    # full IPA. Return the joined result for the short one. The superscripts 
    # are added when the common parts have that or removed if the non common
    # parts override them.
    def join_ipa(full_sp, short_sp)
      # understand -sd-; preparation -Sddss-; imaginary -dssds-
      # plagiarise -ssdddsss; dictionary -dsss; painting -sdss
      #   harmfully -d
      # toxic ssddd-; privacy sssd-; formally sssd-; harmful ssssds-
      full, basesp = full_sp[:baseipa], full_sp[:sindex]
      short, ussp = short_sp[:baseipa], short_sp[:sindex]
      slen = short.length
      flen = full.length
      if short[0] == '-'
        # head-tail hyphen
        if short[-1] == '-'
          center = short[1, slen-2]
          position = full.index(center[0])
          # match left 
          if position && (slen - 2 < flen - 1 - position)
            findex = mix_spi(basesp, 0..position-1, ussp, position-1, 
              basesp, position+slen-2..flen-1)
            ret = full[0..position-1] + center + full[position+slen-2..flen-1]
            return {baseipa: ret, sindex: findex}
          end
          position = full.index(center[-1])
          # match right
          if position && (position + 1 > slen - 2)
            findex = mix_spi(basesp, 0..position-slen+2, ussp, position-slen+2,
              basesp, position+1..flen-1)
            ret = full[0..position-slen+2] + center + full[position+1..flen-1]
            return {baseipa: ret, sindex: findex}
          end
          # this is a simple solution to workaround the issue since no common
          # chars are found between the full and short ipa. Such as the word
          # 'difference', so just assign full to short
          begin
            raise "head-tail hyphen IPA #{short} for the word #{@word}" +
              "unmatched with #{full}."
          rescue RuntimeError
            return full_sp
          end
        else
          # head hyphen
          right = short[1, slen-1]
          position = full.index(right[0])
          # match left #&& plagiarism fails this test
          if position #&& (flen-position >= slen-1)
            findex = mix_spi( basesp, 0..position-1, ussp, position-1)
            ret = full[0..position-1] + right 
            return {baseipa: ret, sindex: findex}
          end
          position = full.index(right[-1])
          # match right
          if position && (position+1 >= slen-1)
            findex = mix_spi(basesp, 0..position-slen+1, ussp, position-slen+1)
            ret = full[0..position-slen+1] + right
            return {baseipa: ret, sindex: findex}
          end
          # unmatched case, like harmfulness
          findex = mix_spi(basesp, 0..flen-1, ussp, flen-1)
          ret = full + right
          return {baseipa: ret, sindex: findex}
        end
      # tail hyphen
      elsif short[-1] == '-'
        left = short[0, slen-1]
        # match left
        # set to true when first one or two chars are identical
        one = two = nil 
        # unicode of secondary stress & stress mark are considered
        if  ["\u{2cc}", "\u{2c8}"].include? left[0]
          two = true if left[0,2] == full[0,2]
        else
          one = true if left[0] == full[0]
        end
        if one or two
          ret = left + full[slen-1..flen-1]  
          findex = mix_spi( ussp, 0, basesp, slen-1..flen-1)
          return {baseipa: ret, sindex: findex}
        else
          raise NotImplementedError, 
            "tail hyphen has uncovered case - code needs update."
        end
      else
        raise ArgumentError,
          "IPA doesn't begin or end with a hyphen, nothing is done."
      end
    end

    # Determine whether or not the range is included by the superscript index.
    # Return the pair of index array when it is included by that. Or return nil.
    def at_range(spindex, range) 
      return if spindex.nil?
      ret = []
      spindex.each_pair { |position, len|
        ret += [position, len] if range.include? position  
      }
      return nil if ret.empty?
      ret
    end
    
    # Mix the superscript index. Return mixed result or nil if no superscript.
    # Each pair of array element is superscript index and a Range/Fixnum.
    # All of them are part of two superscripts that need joining. Only the 
    # superscripts in range are kept, and the index of the superscript with
    # a number is increased by this number. Finally, the joined superscript is 
    # returned.
    def mix_spi(*p)
      findex = []
      p.each_pair { |spindex, r_or_n|
        if spindex and r_or_n.kind_of? Range
          aindex = at_range(spindex, r_or_n) 
          findex += aindex if aindex
        elsif spindex and r_or_n.is_a? Fixnum
          bindex = []
          spindex.each_pair { |p, i|
            bindex += [p + r_or_n, i]
          }
          findex += bindex unless bindex.empty?
        end
      }
      return nil if findex.empty?
      findex
    end

    # Get the UK/US pronunciation mp3/ogg links
    def get_pronunciation
      # parameter pron is a Nokigiri::Node
      links = lambda { |pron|
        unless pron.empty?
          pron.each { |a| 
            return Link.new a['data-src-mp3'], a['data-src-ogg']
          }
        else
          return Link.new
        end
      }
      ukpron = uspron = []
      loc = where?
      loc = [loc] if loc.is_a? String
      loc.each { |loca|
        case loca
        when 'title', 'spellvar'
          ukpron = @html.css(".di-info a.pron-uk")
          uspron = @html.css(".di-info a.pron-us")
        when 'derived'
          derived_css("a.pron-uk") { |node|
            ukpron = node
          }
          derived_css("a.pron-us") { |node|
            uspron = node
          }
        end
      }
      uklinks = links.call(ukpron) 
      uslinks = links.call(uspron) 
      Pronunciation.new(uklinks, uslinks)
    end
    
    # Get a word or phrase's region. Possible values: UK, US.
    def get_region
      ret = nil
      loc = where?
      loc = [loc] if loc.is_a? String
      loc.each { |loca|
        case loca
        when 'title', 'idiom'
          ret = css_text(".di-info > .lab .region")
          ret = css_text(".di-info > .lab") unless ret && !ret.empty? 
        when 'spellvar'
          ret = css_text(".spellvar .region")
        when 'head_variant'
          ret = css_text(".di-info .var .region")
        when 'derived'
          derived_css(".region") { |node|
            ret = node.text unless node.empty?
          }
        when 'phrase'
          phrase_css(".region") { |node|
            ret = node.text unless node.empty?
          }
        end
      }
      ret
    end

    # Parse and get the usage
    def get_usage
      ret = nil
      loc = where?
      loc = [loc] if loc.is_a? String
      loc.each { |loca|
        case loca
        when 'title', 'idiom', 'spellvar'
          ret = css_text(".di-info > .lab .usage")
        when 'head_variant'
          ret = css_text(".di-info .var .usage")
        when 'derived'
          derived_css(".usage") { |node|
            ret = node.text unless node.empty?
          }
        when 'phrase'
          phrase_css(".usage") { |node|
            ret = node.text unless node.empty?
          }
        end
      }
      ret
    end

    # Get grammar code
    def get_gc
      ret = nil
      loc = where?
      loc = [loc] if loc.is_a? String
      loc.each { |loca|
        case loca
        when 'title', 'idiom', 'spellvar', 'head_variant'
          ret = css_text(".di-info .gcs")
        when 'derived'
          derived_css(".gcs") { |node|
            ret = node.text unless node.empty?
          }
        when 'phrase'
          phrase_css(".gcs") { |node|
            ret = node.text unless node.empty?
          }
        end
      }
      ret
    end

    # Return values: String, [String], nil
    def get_plural
      return unless @part_of_speech.include? 'noun'
      ret = nil
      node = @html.css(".di-info .inf-group[type='plural'] .inf")
      unless node.empty?
        # fish has two
        if node.size > 1
          ret = node.map { |n| n.text }
        elsif node.size == 1
          ret = node.text
        end
      end
      ret
    end

    # Parse and get the guided word
    def get_guided_word
      gw = css_text(".di-info .gw")
      gw.delete "()" if gw
    end

    # Return nil or Irregular struct
    def get_irregular
      return unless @part_of_speech.include? 'verb'
      present = css_text(".di-info .inf-group[type='pres_part'] .inf")
      past = css_text(".di-info .inf-group[type='past'] .inf")
      sp = pp = past
      if past.nil? || past.empty?
        node = @html.css(".di-info span[class='inf']") 
        unless node.empty?
          past = node.map { |n| n.text }
          sp, pp = past
        end
      end
      sp = css_text(".di-info .inf-group[type='past-tense'] .inf") if sp.nil?
      pp = css_text(".di-info .inf-group[type='past-part'] .inf") if pp.nil?
      if sp || pp || present
        return Irregular.new(sp, pp, present)
      end
    end

    include Camdict::Common
    # Limitation: some irregular words are not reachable(phenomena, arisen)
    # because they are not shown on the search result page. They can be got 
    # by their original forms - phenomenon, arise.

  end
end
