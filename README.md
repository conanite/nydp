# `'nydp`

`'nydp` is a new LISP dialect, much inspired by [Arc](http://arclanguage.org/), and hence indirectly by all of `'arc`'s ancestors,
and implemented in Ruby.

`'nydp` is "Not Your Daddy's Parentheses", a reference to [Xkcd 297](http://xkcd.com/297/) (itself a reference
to Star Wars), as well as to the meme [Not Your Daddy's Q](http://tvtropes.org/pmwiki/pmwiki.php/Main/NotYourDaddysX), where Q is a
modern, improved Q quite unlike the Q your daddy used. `'nydp` also shamelessly piggypacks on the
catchiness and popularity of the [NYPD](https://en.wikipedia.org/wiki/NYPD_Blue) abbreviation ("New York Police Department",
for those who have no interest in popular US politics or TV).

We do not wish to suggest by "Not Your Daddy's Parentheses" that Common Lisp, Scheme, Racket, Arc, Clojure or your favourite
other lisp are somehow old-fashioned, inferior, or in need of improvement in any way.

The goal of `'nydp` is to allow untrusted users run sandboxed server-side scripts. By default, `'nydp` provides no system access :

* no file functions
* no network functions
* no IO other than $stdin and $stdout
* no process functions
* no threading functions
* no ruby calls

[Peruse `'nydp`'s features here](lib/lisp/tests) in the `tests` directory.

Pronunciation guide: there is no fixed canonical pronunciation of `'nydp`. Just keep in mind that if you find yourself
wading _knee-deep_ through raw sewage, it's still better than working on a java project in a bank.

## Running

#### Get a REPL :

```Shell
$ bundle exec bin/nydp
welcome to nydp
^D to exit
nydp >
```

The REPL uses the readline library so you can use up- and down-arrows to navigate history.

#### Invoking from Ruby

Suppose you want to invoke the function named `question` with some arguments. Do this:

```ruby
ns     = Nydp.build_nydp     # keep this for later re-use, it's expensive to set up

answer = Nydp.apply_function ns, :question, :life, ["The Universe" and(everything)]

==> 42
```

`ns` is just a plain old ruby hash, mapping ruby symbols to nydp symbols for quick lookup at nydp compile-time. The nydp symbols maintain the values of global variables, including all builtin functions and any other functions defined using `def`.

You can maintain multiple `ns` instances without mutual interference. In other words, assigning global variables while one `ns` is in scope will not affect the values of variables in any other `ns` (unless you've specifically arranged it to be so by duplicating namespaces or some such sorcery).


## Different from Arc :

#### 1. Macro-expansion runs in lisp

After parsing its input, `'nydp` passes the result as an argument to the `pre-compile` function. This is where things get a little bit circular: initially, `pre-compile` is a builtin function that just returns its argument. `pre-compile` bootstraps itself into existence in [boot.nydp](lib/lisp/boot.nydp).

You can override `pre-compile` to transform the expression in any way you wish. By default, the `boot.nydp` implementation of `pre-compile` performs macro-expansion.



```lisp
(def pre-compile (expr)
  (map pre-compile
    (if (mac-names (car expr))
        (pre-compile (mac-expand (car expr) (cdr expr)))
        expr)))

(mac yoyo (thing) `(do-yoyo ,thing))

nydp > (pre-compile '(yoyo 42))

==> (do-yoyo 42)
```


#### 2. Special symbol syntax

The parser detects syntax embedded in smybol names and emits a form whose first element names the syntax used. Here's an example:

```lisp

nydp > (parse "x.y")

==> (dot-syntax x y)

nydp > (parse "$x x$ x$x $x$ $$")

==> (dollar-syntax || x)     ; '|| is the empty symbol.
==> (dollar-syntax x ||)
==> (dollar-syntax x x)
==> (dollar-syntax || x ||)
==> (dollar-syntax || || ||)

nydp > (parse "!foo")

==> (bang-syntax || foo)

nydp > (parse "!x.$y")

==> (bang-syntax || (dot-syntax x (dollar-syntax || y)))

```

Nydp provides macros for some but not all possible special syntax

```lisp
nydp > (pre-compile 'x.y)

==> (hash-get x 'y) ; 'dot-syntax is a macro that expands to perform hash lookups

nydp > (pre-compile 'x.y.z)

==> (hash-get (hash-get x 'y) 'z)


nydp > (pre-compile '!eq?)

==> (fn args (no (apply eq? args)))

nydp > (pre-compile '(!eq? a b))

==> ((fn args (no (apply eq? args))) a b) ; equivalent to (no (eq? a b))
```

Ampersand-syntax - for example `&foo`, expands to a function which performs a hash-lookup on its argument.

```lisp

nydp > (parse "&foo")
((ampersand-syntax || foo))

nydp > (pre-compile (parse "&foo"))
((fn (obj) (hash-get obj (quote foo))))

nydp > (assign hsh { foo 1 bar 2 })
nydp > (&bar hsh)
2

nydp > (&lastname (car german-composers))
Bach

nydp > (map &lastname german-composers)   ; ampersand-syntax creates a function you can pass around
(Bach Beethoven Wagner Mozart)

```

As with all other syntax, you can of course override the `ampersand-syntax` macro to handle your special needs.

Look for `SYMBOL_OPERATORS` in [parser.rb](lib/nydp/parser.rb) to see which syntax is recognised and in which order. The order of these definitions defines special-syntax-operator precedence.

#### 3. Special list syntax

The parser detects alternative list delimiters

```lisp
nydp > (parse "{ a 1 b 2 }")

==> (brace-list a 1 b 2)

```

`brace-list` is a macro that expands to create a hash literal. It assumes every item 0 is a literal symbol key, item 1 is the corresponding value which is evaluated at run time, and so on for each following item-pair.

```lisp

nydp > { a 1 b (author-name) }

==> {a=>1, b=>"conanite"}

```



#### 4. Sensible, nestable string interpolation

The parser detects lisp code inside strings. When this happens, instead of emitting a string literal, the parser emits a form whose car is the symbol `string-pieces`.

```lisp
nydp > (parse "\"foo\"")

==> "foo"

nydp > (let bar "Mister Nice Guy" "hello, ~bar")

==> "hello, Mister Nice Guy"

; this is a more tricky example because we need to make a string with an interpolation token in it

nydp > (let s (joinstr "" "\"hello, " '~ "world\"") (parse s))

==> (string-pieces "hello, " world "") ; "hello, ", followed by the interpolation 'world, followed by the empty string after 'world

; It is possible to nest interpolations. Note that as with many popular language features, just because you can do something, does not mean you should:

nydp > (def also (str) "\nAND ALSO, ~str")
nydp > (with (a 1 b 2)
         (p "Consider ~a : the first thing,
              ~(also "Consider ~b : the second thing,
              ~(also "Consider ~(+ a b), the third (and final) thing")")"))

==> Consider 1 : the first thing,
==> AND ALSO, Consider 2 : the second thing,
==> AND ALSO, Consider 3, the third (and final) thing
```

By default, `string-pieces` is a function that just concatenates the string value of its arguments. You can redefine it as a macro to
perform more fun stuff, or you can detect it within another macro to do extra-special stuff with it. The 'nydp-html gem detects
'string-pieces and gives it special treatment in order to render haml and textile efficiently, and also to capture and report errors
inside interpolations and report them correctly.


#### 5. No continuations.

Sorry. While technically possible ... why bother?


#### 6. No argument destructuring

However, this doesn't need to be built-in, it can be done with macros alone. On the other hand, "rest" arguments are implicitly available using the same syntax as Arc uses:

```lisp
(def fun (a b . others) ...)
```

In this example, `'others` is either nil, or a list containing the third and subsequent arguments to the call to `'fun`. For many examples of this kind of invocation, see [invocation-tests](lib/lisp/tests/invocation-tests.nydp) in the `tests` directory.



## Besides that, what can Nydp do?

#### 1. Functions and variables exist in the same namespace.
#### 2. Macros are maintained in a hash called 'macs in the main namespace.
#### 3. General [tail call elimination](https://en.wikipedia.org/wiki/Tail_call) allowing recursion without stack overflow in some cases.
#### 4. 'if like Arc:

```lisp
(if a b c d e) ; equivalent to ruby :
```

```ruby
if    a
      b
elsif c
      d
else  e
```

#### 5. Lexically scoped, but dynamic variables possible, using thread-locals

```lisp
nydp> (dynamic foo) ;; declares 'foo as a dynamic variable

nydp> (def do-something () (+ (foo) 1))

nydp> (w/foo 99 (do-something)) ;; sets 'foo to 99 for the duration of the call to 'do-something, will set it back to its previous value afterwards.

==> 100

nydp> (foo)

==> nil
```

#### 6. Basic error handling

```lisp
nydp> (on-err (p "error")
        (ensure (p "make sure this happens")
          (/ 1 0)))

make sure this happens
error
```

#### 7 Intercept comments

```lisp
nydp > (parse "; blah blah")

==> (comment "blah blah")
```

Except in 'mac and 'def forms, by default, `comment` is a macro that expands to nil. If you have a better idea, go for it. Any comments present at the
beginning of the `body` argument to `mac` or `def` are considered documentation. (See "self-documenting" below).

#### 8 Prefix lists

The parser emits a special form if it detects a prefix-list, that is, a list with non-delimiter characters immediately preceding
the opening delimiter. For example:

```lisp
nydp > (parse "%w(a b c)")

==> (prefix-list "%w" (a b c))
```

This allows for preprocessing lists in a way not possible for macros. nydp uses this feature to implement shortcut oneline
functions, as in

```lisp
nydp > (parse "λx(len x)")

==> ((prefix-list "λx" (len x)))

nydp > (pre-compile '(prefix-list "λx" (len x)))

==> (fn (x) (len x))
```

Each character after 'λ becomes a function argument:

```lisp
nydp > (parse "λxy(* x y)")

==> ((prefix-list "λxy" (* x y)))

nydp > (pre-compile '(prefix-list "λxy" (* x y)))

==> (fn (x y) (* x y))
```

Use 'define-prefix-list-macro to define a new handler for a prefix-list. Here's the code for the 'λ shortcut:

```lisp
(define-prefix-list-macro "^λ.+" vars expr
  (let var-list (map sym (cdr:string-split vars))
    `(fn ,var-list ,expr)))
```

In this case, the regex matches an initial 'λ ; there is no constraint however on the kind of regex a prefix-list-macro might use.


#### 9 Self-documenting

Once the 'dox system is bootstrapped, any further use of 'mac or 'def will create documentation.

Any comments at the start of the form body will be used to generate help text. For example:

```lisp
nydp > (def foo (x y)
         ; return the foo of x and y
         (* x y))

nydp > (dox foo)

Function : foo
args : (x y)
return the foo of x and y

source
======
(def foo (x y)
    (* x y))
```

'dox is a macro that generates code to output documentation to stdout. 'dox-lookup is a function that returns structured documentation.

```lisp
nydp > (dox-lookup 'foo)
((foo def ("return the foo of x and y") (x y) (def foo (x y) (* x y))))
```

Not as friendly, but more amenable to programmatic manipulation. Each subsequent definition of 'foo (if you override it, define
it as a macro, or define it again in some other context) will generate a new documentation structure, which will simply be preprended to
the existing list.

#### 10 Pretty-Printing

'dox above uses the pretty printer to display code source. The pretty-printer is hard-coded to handle some special cases,
so it will unparse special syntax, prefix-lists, quote, quasiquote, unquote, and unquote-splicing.

You can examine its behaviour at the repl:

```lisp
nydp > (p:pp '(string-pieces "hello " (bang-syntax || (dot-syntax x y (ampersand-syntax foo bar))) " and welcome to " (prefix-list "%%" (a b c d)) " and friends!"))

==> "hello ~!x.y.foo&bar and welcome to ~%%(a b c d) and friends!"

nydp > (p:pp:dox-src 'pp/find-breaks)

(def pp/find-breaks (form)
    (if (eq? 'if (car form))
      (let if-args (cdr form)
        (cons (list 'if (car if-args)) (map list (cdr if-args))))
      (or
        (pp/find-breaks/mac form)
        (list form))))
```

The pretty-printer is still rather primitive in that it only indents according to some hard-coded rules, and according to argument-count
for documented macros. It has no means of wrapping forms that get too long, or that extend beyond a certain predefined margin or column number.

## Installation

Add this line to your application's Gemfile:

    gem 'nydp'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nydp


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
