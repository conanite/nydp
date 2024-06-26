module Nydp
  class Parser
    def sym name
      n = name.to_s.to_sym
      if n == :nil
        nil
      elsif n == :t
        true
      else
        n
      end
    end

    def read_list token_stream, termination_token, list=[]
      token = token_stream.next_token
      while token != nil && token.first != termination_token
        list << next_form(token, token_stream)
        token = token_stream.next_token
      end
      Pair.parse_list list
    end

    def prefix_list prefix, list
      return list if prefix == ''
      case prefix
      when /^(.*)'$/
        prefix_list $1, Pair.from_list([sym(:quote), list])
      when /^(.*)`$/
        prefix_list $1, Pair.from_list([sym(:quasiquote), list])
      when /^(.*),$/
        prefix_list $1, Pair.from_list([sym(:unquote), list])
      when /^(.*),@$/
        prefix_list $1, Pair.from_list([sym(:"unquote-splicing"), list])
      else
        Pair.from_list([sym(:"prefix-list"), prefix, list])
      end
    end

    def split_sym syms, pfx
      return Pair.from_list [pfx] + syms.map { |s| parse_symbol s }
    end

    SOLO_OPERATORS = [ /^@$/, /^\*$/, /^\.$/ ]

    SYMBOL_OPERATORS =
      [
        [ /\!/,     "bang-syntax"       ],
        [ /::/,     "colon-colon-syntax"],
        [ /:/,      "colon-syntax"      ],
        [ /&/,      "ampersand-syntax"  ],
        [ /%/,      "percent-syntax"    ],
        [ /\./,     "dot-syntax"        ],
        [ /\$/,     "dollar-syntax"     ],
        [ /->/,     "arrow-syntax"      ],
        [ /[=][>]/, "rocket-syntax"     ],
        [ /@/,      "at-syntax"         ],
        # [ /\*/,     "asterisk-syntax"   ],
      ]

    def parse_symbol txt
      txt = txt.to_s
      case txt
      when /^[-+]?[0-9]*\.[0-9]+([eE][-+]?[0-9]+)?$/
        txt.to_f
      when /^[-+]?[0-9]+$/
        txt.to_i
      when /^'(.*)$/
        Pair.from_list [sym(:quote), parse_symbol($1)]
      when /^`(.*)$/
        Pair.from_list [sym(:quasiquote), parse_symbol($1)]
      when /^,@(.*)$/
        Pair.from_list [sym(:"unquote-splicing"), parse_symbol($1)]
      when /^,(.*)$/
        Pair.from_list [sym(:unquote), parse_symbol($1)]
      when *SOLO_OPERATORS
        sym txt
      else
        SYMBOL_OPERATORS.each do |rgx, name|
          syms = txt.split(rgx, -1)
          return split_sym syms, sym(name) if syms.length > 1
        end

        sym txt
      end
    end

    def close_delimiter_for opener
      case opener
      when '"'
        /"/
      when /.*{$/
        /}/
      when /<<(.+)$/
        Regexp.new $1
      end
    end

    def next_form token, token_stream
      return nil if token.nil?
      case token.first
      when :string_open_delim
        string token_stream, token.last, close_delimiter_for(token.last)
      when :sym_open_delim
        sym token_stream.next_string_fragment(token.last, /\|/, nil).string
      when :left_paren
        prefix_list token[1], read_list(token_stream, :right_paren)
      when :left_brace
        prefix_list token[1], read_list(token_stream, :right_brace, [sym("brace-list")])
      when :symbol
        parse_symbol token.last
      when :comment
        Pair.from_list [sym(:comment), token.last]
      else
        token.last
      end
    end

    def expression token_stream
      next_form token_stream.next_token, token_stream
    end

    INTERPOLATION_SIGN = /~/
    INTERPOLATION_ESCAPES = { /~\s/ => true, /~~/ => "~" }

    def embedded token_stream
      string token_stream, "", :eof
    end

    def string token_stream, open_delimiter, close_delimiter
      fragments = [sym(:"string-pieces")]
      string_token = token_stream.next_string_fragment(open_delimiter, close_delimiter, INTERPOLATION_SIGN, INTERPOLATION_ESCAPES)
      raise "unterminated string" if string_token.nil?
      fragments << string_token.string if string_token.string != ""
      while !(string_token.is_a? StringFragmentCloseToken)
        fragments << expression(token_stream)
        string_token = token_stream.next_string_fragment('', close_delimiter, INTERPOLATION_SIGN, INTERPOLATION_ESCAPES)
        fragments << string_token.string if string_token.string != ""
      end

      if fragments.size == 1
        return ""
      elsif fragments.size == 2
        return fragments[1]
      else
        return Pair.from_list fragments
      end
    end
  end
end
