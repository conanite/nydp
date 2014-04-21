module Nydp
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

  def self.NIL
    @@nil
  end
end
