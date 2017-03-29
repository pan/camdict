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
    word = Camdict::Word.new 'health'

    # Print the part of speech
    puts health.part_of_speech   #=> noun

    # What's the first meaning
    puts health.meaning          #=>
    # the condition of the body and the degree to which it is free from
    # illness, or the state of being well:

    # all meanings
    puts health.meanings         #=> in addition to above meaning, it prints
    # the condition of something that changes or develops, such as an
    # organization or system:

```

Need more? try `health.print` to show more data in a friendly format.

## Versioning
The release of this gem follows the [semantic versioning rule][2].

## Licence MIT
Copyright (c) 2014-2017 Pan Gaoyong

[1]: http://dictionary.cambridge.com "Cambridge"
[2]: http://semver.org
