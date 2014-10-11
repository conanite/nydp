module Nydp
  class StringAtom
    attr_accessor :string, :token
    def initialize string, token
      @string, @token = string, token
    end

    def to_s
      string
    end

    def inspect
      token.rep
    end

    def == other
      other.to_s == self.to_s
    end
  end
end
