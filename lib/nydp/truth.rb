require 'singleton'

module Nydp
  class Truth
    include Singleton
    def init_with *; Nydp::T          ; end
    def to_s       ; 't'              ; end
    def inspect    ; 't[nydp::Truth]' ; end
    def assign  *_ ; self             ; end
    def nydp_type  ; :truth           ; end
    def to_ruby    ; true             ; end
  end

  class Nil
    include Singleton
    def init_with * ; Nydp::NIL     ; end
    def car         ; self          ; end
    def cdr         ; self          ; end
    def size        ; 0             ; end
    def is?   other ; other.class == self.class ; end
    def isnt? other ; other.class != self.class ; end
    def to_s        ; ""            ; end
    def + other     ; other         ; end
    def copy        ; self          ; end
    def assign *_   ; self          ; end
    def inspect     ; "nil"         ; end
    def nydp_type   ; :nil          ; end
    def to_ruby     ; nil           ; end
    def execute vm  ; vm.push_arg self ; end
  end

  NIL = Nil.instance
  T   = Truth.instance
end
