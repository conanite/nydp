module Nydp
  class StringAtom
    attr_accessor :string, :token
    def initialize string, token=nil
      @string, @token = string, token
    end

    def nydp_type  ; :string        ; end
    def to_s       ;  string        ; end
    def to_ruby    ;  string        ; end
    def to_sym     ;  string.to_sym ; end
    def eql? other ; self == other  ; end
    def inspect    ; string.inspect ; end
    def hash       ; string.hash    ; end
    def length     ; string.length  ; end
    def > other    ; self.string > other.string ; end
    def < other    ; self.string < other.string ; end

    def <=> other
      self < other ? -1 : (self == other ? 0 : 1)
    end

    def == other
      other.is_a?(Nydp::StringAtom) && (other.to_s == self.to_s)
    end

    def + other
      StringAtom.new "#{@string}#{other}"
    end
  end
end
