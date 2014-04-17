module Nydp
  class Nil
    def car;  self; end
    def cdr;  self; end
    def size; 0   ; end
    def is? other
      other == self
    end
  end

  NIL = Nil.new  
end
