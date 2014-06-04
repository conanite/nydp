module Nydp
  class Parser
    attr_accessor :ns

    def initialize ns
      @ns = ns
    end

    def sym name
      Nydp::Symbol.mk name, ns
    end

    def read_list token_stream, termination_token
      list = []
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
        sym txt
      end
    end

    def next_form token, token_stream
      return Nydp.NIL if token.nil?
      case token.first
      when :left_paren
        prefix_list token[1], read_list(token_stream, :right_paren)
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
  end
end
