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
      "nil"
    end
  end

  NIL = Nil.new
end
