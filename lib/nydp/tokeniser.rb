require "strscan"

module Nydp
  class Tokeniser
    BACKSLASH = /\\/.freeze
    COMMENT   = /;;?.*$/.freeze
    QUOTE     = /"/.freeze
    PIPE      = /\|/.freeze
    LIST_PFX  = /[^\s()]*\(/.freeze
    BRACE_PFX = /[^\s()\}\{]*\{/.freeze
    RPAREN    = /\)/.freeze
    RBRACE    = /\}/.freeze
    FLOAT     = /[-+]?[0-9]*\.[0-9]+([eE][-+]?[0-9]+)?/.freeze
    INTEGER   = /[-+]?[0-9]+/.freeze
    ATOM_PIPE = /[^\s()"{}\|]+\|/.freeze
    ATOM      = /[^\s()"{}\|]+/.freeze

    attr_accessor :state, :finished

    def initialize reader
      @reader = reader
      @scanner = StringScanner.new("")
    end

    def no_more?
      if @scanner.eos?
        nextline = @reader.nextline
        return true if nextline.nil?
        @scanner << nextline
      end

      false
    end

    def close_delimiter? scanner, delim
      return (no_more? ? '' : nil) if (delim == :eof)
      scanner.scan(delim)
    end

    def next_string_fragment open_delimiter, close_delimiter, interpolation_sign, interpolation_escapes={ }
      s = @scanner
      rep = open_delimiter.to_s
      string = ""
      while (!no_more?)
        if esc = s.scan(BACKSLASH)
          rep    << esc
          ch = s.getch
          case ch
            when "n" ; string << "\n"
            when "t" ; string << "\t"
            else       string << ch
          end
          rep << ch
        elsif closer = close_delimiter?(s, close_delimiter)
          rep << closer
          return StringFragmentCloseToken.new(string, rep)
        elsif interpolation_sign
          escaped = false
          interpolation_escapes.each do |esc, repl|
            if !escaped && (escape = s.scan esc)
              string << ((repl == true) ? escape : repl)
              rep    << escape
              escaped = true
            end
          end
          if !escaped && (start_interpolation = s.scan(interpolation_sign))
            rep << start_interpolation
            return StringFragmentToken.new(string, rep)
          else
            ch = s.getch
            string << ch
            rep    << ch
          end
        else
          ch = s.getch
          string << ch
          rep    << ch
        end
      end

      return StringFragmentCloseToken.new(string, rep) if close_delimiter == :eof
    end

    def next_token
      s = @scanner
      tok = nil
      while !tok
        if no_more?
          @finished = true
          return nil
        elsif comment = s.scan(COMMENT)
          tok = [:comment, comment.gsub(/^;;?\s?/, '')]
        elsif open_str = s.scan(QUOTE)
          tok = [:string_open_delim, open_str]
        elsif open_sym = s.scan(PIPE)
          tok = [:sym_open_delim, open_sym]
        elsif list_prefix = s.scan(LIST_PFX)
          tok = [:left_paren, list_prefix[0...-1]]
        elsif list_prefix = s.scan(BRACE_PFX)
          tok = [:left_brace, list_prefix[0...-1]]
        elsif s.scan(RPAREN)
          tok = [:right_paren]
        elsif s.scan(RBRACE)
          tok = [:right_brace]
        elsif number = s.scan(FLOAT)
          tok = [:number, number.to_f]
        elsif integer = s.scan(INTEGER)
          tok = [:number, integer.to_i]
        elsif atom = s.scan(ATOM_PIPE)
          atom = atom[0...-1]
          rest = next_string_fragment("|", PIPE, nil) || Nydp::StringFragmentToken.new("", "")
          tok = [:symbol, "#{atom}#{rest.string}"]
        elsif atom = s.scan(ATOM)
          tok = [:symbol, atom]
        else
          s.getch
        end
      end
      tok
    end
  end
end
