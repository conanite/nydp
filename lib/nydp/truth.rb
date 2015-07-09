module Nydp
  class Truth
    def to_s      ; 't'              ; end
    def inspect   ; 't[nydp::Truth]' ; end
    def assign *_ ; self             ; end
    def nydp_type ; :truth           ; end
  end

  class Nil
    def car         ; self          ; end
    def cdr         ; self          ; end
    def size        ; 0             ; end
    def is?   other ; (self.equal? other) ; end
    def isnt? other ; !is?(other)   ; end
    def to_s        ; ""            ; end
    def + other     ; other         ; end
    def copy        ; self          ; end
    def assign *_   ; self          ; end
    def inspect     ; "nil"         ; end
    def nydp_type   ; :nil          ; end

    def execute vm
      vm.push_arg self
    end

    def repush _, contexts
      contexts.pop
    end
  end

  @@nil = Nil.new
  @@t   = Truth.new

  class Nil
    def self.new ; raise "no" ; end
  end

  def self.NIL; @@nil; end
  def self.T;   @@t;   end
end
