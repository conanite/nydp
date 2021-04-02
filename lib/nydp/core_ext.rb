class Object
  def _nydp_get     a ; raise "_nydp_get : not gettable: #{a.inspect} on #{self.class.name}" ; end
  def _nydp_set  a, v ; raise "_nydp_get : not settable: #{a.inspect} on #{self.class.name}" ; end
  def _nydp_keys      ; []   ; end
  def _nydp_wrapper   ; self ; end
  def lexical_reach n ; n    ; end
end

class Method
  include Nydp::Converter
  def invoke_1 vm             ; vm.push_arg call._nydp_wrapper                            ; end
  def invoke_2 vm, a0         ; vm.push_arg call(n2r(a0))._nydp_wrapper                   ; end
  def invoke_3 vm, a0, a1     ; vm.push_arg call(n2r(a0), n2r(a1))._nydp_wrapper          ; end
  def invoke_4 vm, a0, a1, a2 ; vm.push_arg call(n2r(a0), n2r(a1), n2r(a2))._nydp_wrapper ; end
  def invoke   vm, args       ; vm.push_arg call(*(args.map { |a| n2r a}))._nydp_wrapper  ; end
end

class NilClass
  def _nydp_wrapper ; Nydp::NIL ; end
end

class FalseClass
  def _nydp_wrapper ; Nydp::NIL ; end
end

class TrueClass
  def _nydp_wrapper ; Nydp::T ; end
end

class ::Symbol
  def _nydp_wrapper ; Nydp::FrozenSymbol.mk(self) ; end
end

class ::Date
  def _nydp_wrapper ; Nydp::Date.new self ; end
end

class ::Array
  def _nydp_wrapper ; Nydp::Pair.from_list map &:_nydp_wrapper ; end
end

class ::Object
  def to_ruby        ; self                       ; end
end

class ::String
  # def _nydp_wrapper  ; Nydp::StringAtom.new self  ; end
  def as_method_name ; self.gsub(/-/, '_').to_sym ; end
  def nydp_type      ; :string                    ; end
end

class ::Hash
  include Nydp::Helper
  def _nydp_get a    ; self[n2r a]           ; end
  def _nydp_set a, v ; self[n2r a] = n2r(v)  ; end
  def _nydp_keys     ; keys                  ; end
end
