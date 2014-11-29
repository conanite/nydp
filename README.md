# Nydp

NYDP is "Not Your Daddy's Parentheses", a reference to [Xkcd 297](http://xkcd.com/297/) (itself a reference
to Star Wars), as well as to the meme [Not Your Daddy's Q](http://tvtropes.org/pmwiki/pmwiki.php/Main/NotYourDaddysX), where Q is a modern,
improved Q unlike the Q your daddy used. "NYDP" also shamelessly piggypacks on the
catchiness and popularity of the [NYPD](https://en.wikipedia.org/wiki/NYPD_Blue) abbreviation ("New York Police Department",
for those who have no interest in popular US TV or authoritarian politics).

Macro-expansion is not built-in to the interpreter; however, the compiler will invoke 'pre-compile before compiling, passing
the expression to compile as an argument. You can override 'pre-compile to transform the expression in any way you wish. By default,
nydp provides an implementation of 'pre-compile that performs macro-expansion.

```
(def pre-compile (expr)
  (map pre-compile
    (if (mac-names (car expr))
        (pre-compile (mac-expand (car expr) (cdr expr)))
        expr)))
```

; blah blah

```
  ==> (comment "blah blah")

  ==> (mac comment (txt) nil)
```

We do not wish to suggest by "Not Your Daddy's Parentheses" that Common Lisp,
Scheme, Racket, Arc, Clojure or your favourite other lisp are somehow
old-fashioned, inferior, or in need of improvement in any way.


## Installation

Add this line to your application's Gemfile:

    gem 'nydp'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nydp

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
