module Nydp
  class Truth
  end

  class Nil
    def car;  self; end
    def cdr;  self; end
    def size; 0   ; end
    def is?   other; other == self; end
    def isnt? other; other != self; end

    def to_s
      "nil"
    end

    def inspect
      "nil[Nydp::Nil]"
    end
  end

  @@nil = Nil.new
  @@t = Truth.new

  def self.NIL; @@nil; end
  def self.T;   @@t;   end
end
