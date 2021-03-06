module Nydp
  class StringAtom
    attr_accessor :string

    def initialize string ; @string = string ; end

    def nydp_type  ; :string                                     ; end
    def to_s       ; string                                      ; end
    def to_ruby    ; string                                      ; end
    def to_sym     ; string.to_sym                               ; end
    def to_date    ; ::Date.parse(@string)                       ; end
    def eql? other ; self == other                               ; end
    def inspect    ; string.inspect                              ; end
    def hash       ; string.hash                                 ; end
    def length     ; string.length                               ; end
    def >    other ; self.string > other.string                  ; end
    def <    other ; self.string < other.string                  ; end
    def *    other ; StringAtom.new(string * other)              ; end
    def <=>  other ; self < other ? -1 : (self == other ? 0 : 1) ; end
    def +    other ; StringAtom.new "#{@string}#{other}"         ; end

    def == other
      other.is_a?(Nydp::StringAtom) && (other.to_s == self.to_s)
    end
  end
end
