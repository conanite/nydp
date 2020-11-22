require 'singleton'

module Nydp
  class Truth
    include Singleton
    def init_with *; Nydp::T     ; end
    def to_s       ; 't'         ; end
    def inspect    ; 't'         ; end
    def assign  *_ ; self        ; end
    def nydp_type  ; :truth      ; end
    def to_ruby    ; true        ; end
    def _nydp_get    a ; Nydp::T ; end
    def _nydp_set a, v ; Nydp::T ; end
  end

  class Nil
    include Singleton, Enumerable
    def init_with * ; Nydp::NIL     ; end
    def car         ; self          ; end
    def cdr         ; self          ; end
    def size        ; 0             ; end
    def is?   other ; self.equal? other  ; end
    def isnt? other ; !self.equal? other ; end
    def to_s        ; ""            ; end
    def + other     ; other         ; end
    def copy        ; self          ; end
    def assign *_   ; self          ; end
    def inspect     ; "nil"         ; end
    def nydp_type   ; :nil          ; end
    def to_ruby     ; nil           ; end
    def execute     vm ; vm.push_arg self ; end
    def _nydp_get    a ; Nydp::NIL        ; end
    def _nydp_set a, v ; Nydp::NIL        ; end
    def each           ;                  ; end # nil behaves like an empty list
    def &        other ; self             ; end
    def |        other ; other            ; end
  end

  NIL = Nil.instance
  T   = Truth.instance
end
