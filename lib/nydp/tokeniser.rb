require "strscan"

module Nydp
  class Tokeniser
    attr_accessor :state, :finished

    def initialize stream
      @stream = stream.is_a?(String) ? nil : stream
      @scanner = StringScanner.new(stream.is_a?(String) ? stream : "")
      @state = :lisp
    end

    def no_more?
      @scanner << @stream.readline if @scanner.eos? && @stream && !@stream.eof?
      @scanner.eos?
    end

    def close_delimiter? scanner, delim
      return (no_more? ? '' : nil) if (delim == :eof)
      scanner.scan(delim)
    end

    def next_string_fragment open_delimiter, close_delimiter
      s = @scanner
      rep = "#{open_delimiter}"
      string = ""
      while (!no_more?)
        if esc = s.scan(/\\/)
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
        elsif embed_suffix = s.scan(/%%/)
          rep << embed_suffix
          return StringFragmentToken.new(string, rep)
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
        elsif comment = s.scan(/;.*$/)
          tok = [:comment, comment[1..-1].strip]
        elsif open_str = s.scan(/"/)
          tok = [:string_open_delim, open_str]
        elsif embed_suffix = s.scan(/\]#/)
          self.state = :external_text
          tok = [:embed_suffix, embed_suffix]
        elsif list_prefix = s.scan(/[^\s()]*\(/)
          tok = [:left_paren, list_prefix[0...-1]]
        elsif s.scan(/\)/)
          tok = [:right_paren]
        elsif number = s.scan(/[-+]?[0-9]*\.[0-9]+([eE][-+]?[0-9]+)?/)
          tok = [:number, number.to_f]
        elsif integer = s.scan(/[-+]?[0-9]+/)
          tok = [:number, integer.to_i]
        elsif atom = s.scan(/[^\s()]+/)
          tok = [:symbol, atom]
        else
          s.getch
        end
      end
      tok
    end
  end
end
