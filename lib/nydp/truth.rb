module Nydp
  class Truth
    def to_s      ; 't'              ; end
    def inspect   ; 't[nydp::Truth]' ; end
    def assign *_ ; self             ; end
  end

  class Nil
    def car         ; self          ; end
    def cdr         ; self          ; end
    def size        ; 0             ; end
    def is?   other ; other == self ; end
    def isnt? other ; other != self ; end
    def to_s        ; "nil"         ; end
    def + other     ; other         ; end
    def copy        ; self          ; end
    def assign *_   ; self          ; end

    def inspect
      "nil[Nydp::Nil]"
    end

    def execute vm
      vm.push_arg self
    end

    def repush _, contexts
      contexts.pop
    end
  end

  @@nil = Nil.new
  @@t   = Truth.new

  def self.NIL; @@nil; end
  def self.T;   @@t;   end
end
