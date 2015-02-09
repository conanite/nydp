module Nydp
  class StringAtom
    attr_accessor :string, :token
    def initialize string, token=nil
      @string, @token = string, token
    end

    def nydp_type ; :string ; end
    def to_s      ;  string ; end

    def inspect
      token ? token.rep : string.inspect
    end

    def == other
      other.to_s == self.to_s
    end

    def + other
      StringAtom.new "#{@string}#{other}"
    end

  end
end
