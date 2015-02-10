module Nydp
  class StringFragmentToken
    attr_accessor :string, :rep
    def initialize string, rep
      @string, @rep = string, rep
    end

    def to_s
      rep
    end

    def == other
      (self.class == other.class) && (self.string == other.string)
    end
  end

  class StringFragmentCloseToken < StringFragmentToken
  end
end
