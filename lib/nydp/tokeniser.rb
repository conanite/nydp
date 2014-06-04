require "strscan"

module Nydp
  class Tokeniser
    def initialize stream
      @stream = stream
      @scanner = StringScanner.new(stream.is_a?(String) ? stream : "")
    end

    def next_token
      s = @scanner
      tok = nil
      while !tok
        if s.eos?
          return nil if @stream.is_a?(String) || @stream.eof?
          s << @stream.readline
        elsif comment = s.scan(/;.*$/)
          tok = [:comment, comment[1..-1].strip]
        elsif s.scan(/"/)
          string = ""
          while (!s.eos?)
            if s.scan(/\\"/)
              string << '"'
            elsif s.scan(/"/)
              break
            else
              string << s.getch
            end
          end
          tok = [:string, string]
        elsif list_prefix = s.scan(/[^\s()]*\(/)
          tok = [:left_paren, list_prefix[0...-1]]
        elsif s.scan(/\)/)
          tok = [:right_paren]
        elsif number = s.scan(/[-+]?[0-9]*\.[0-9]+([eE][-+]?[0-9]+)?/)
          tok = [:number, number.to_f]
        elsif integer = s.scan(/[-+]?[0-9]+/)
          tok = [:number, integer.to_i]
        elsif atom = s.scan(/[^\s()]+/)
          tok = [:symbol, atom.to_sym]
        else
          s.getch
        end
      end
      tok
    end
  end
end
