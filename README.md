# A ruby gem - camdict

## Introduction 

The ruby gem camdict is a [Cambridge online dictionary][1] client.  
You could use this excellent dictionary with a browser, but now it is possible
to use it with this ruby API in your code.

## Installation
`gem install camdict`

## Verification
The gem can be tested by below commands in the directory where it's installed.  
`rake`         - run all the testcases which don't need internet connection.  
`rake itest`   - run all the testcases that need internet connection.  
`rake testall` - run all above tests.

## Usage

```ruby
    require 'camdict'

    # Look up a new word
    word = Camdict::Word.new "health"

    # get all definitions for this word from remote dictionary and select the
    # first one. A word usually has many definitions.
    health = word.definitions.first

    # Print the part of speech
    puts health.part_of_speech   #=> noun

    # One definition may have more than one explanations. 
    # Just look at the details of the first one.
    explanation1 = health.explanations.first

    # What's the meaning
    puts explanation1.meaning    #=> 
    # the condition of the body and the degree to which it is free from 
    # illness, or the state of being well: 

    # And it may have some useful example sentences.
    explanation1.examples.each { |e|
      puts e.sentence            #=> 
      # to be in good/poor health
      # Regular exercise is good for your health.
      # I had to give up drinking for health reasons.
      # He gave up work because of ill health.
    }
```

There are some useful testing examples in test directory of this gem.

## Licence MIT
Copyright (c) 2014 Pan Gaoyong

[1]: http://dictionary.cambridge.com "Cambridge"
