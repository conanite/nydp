module Nydp
  class Parser
    attr_accessor :ns

    def initialize ns
      @ns = ns
    end

    def sym name
      Nydp::Symbol.mk name.to_sym, ns
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
      case prefix
      when "'"
        Pair.from_list [sym(:quote), list]
      when "`"
        Pair.from_list [sym(:quasiquote), list]
      when ","
        Pair.from_list [sym(:unquote), list]
      when ",@"
        Pair.from_list [sym(:"unquote-splicing"), list]
      else
        list
      end
    end

    def split_sym syms, pfx
      return Pair.from_list [pfx] + syms.map { |s| parse_symbol s }
    end

    def parse_symbol txt
      case txt
      when /^'(.+)$/
        Pair.from_list [sym(:quote), parse_symbol($1)]
      when /^`(.+)$/
        Pair.from_list [sym(:quasiquote), parse_symbol($1)]
      when /^,@(.+)$/
        Pair.from_list [sym(:"unquote-splicing"), parse_symbol($1)]
      when /^,(.+)$/
        Pair.from_list [sym(:unquote), parse_symbol($1)]
      else
        syms = txt.to_s.split /\./
        return split_sym syms, sym("dot-syntax") if syms.length > 1

        syms = txt.split /::/
        return split_sym syms, sym("colon-colon-syntax") if syms.length > 1

        syms = txt.split /:/
        return split_sym syms, sym("colon-syntax") if syms.length > 1

        syms = txt.split /->/
        return split_sym syms, sym("arrow-syntax") if syms.length > 1

        syms = txt.split(/=>/)
        return split_sym syms, sym("rocket-syntax") if syms.length > 1

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
      when :embed_suffix
        Nydp.NIL
      when :string_open_delim
        string token_stream, token.last, close_delimiter_for(token.last)
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

    def string token_stream, open_delimiter, close_delimiter
      fragments = [sym(:"string-pieces")]
      string_token = token_stream.next_string_fragment(open_delimiter, close_delimiter)
      fragments << Nydp::StringAtom.new(string_token.string, string_token)
      while !(string_token.is_a? StringFragmentCloseToken)
        fragments << expression(token_stream)
        string_token = token_stream.next_string_fragment('', close_delimiter)
        fragments << Nydp::StringAtom.new(string_token.string, string_token)
      end

      if fragments.size == 2
        return fragments[1]
      else
        return Pair.from_list fragments
      end
    end
  end
end
