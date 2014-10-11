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
      %i{ string rep class }.inject(true) { |bool, attr|
          bool && (self.send(attr) == other.send(attr))
        }
    end
  end

  class StringFragmentCloseToken < StringFragmentToken
  end
end
