class Object
  def _nydp_get    a ; raise "_nydp_get : not gettable: #{a.inspect} on #{self.class.name}" ; end
  def _nydp_set a, v ; raise "_nydp_get : not settable: #{a.inspect} on #{self.class.name}" ; end
  def _nydp_keys     ; []   ; end
  def _nydp_wrapper  ; self ; end
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

class ::String
  def _nydp_wrapper ; Nydp::StringAtom.new self ; end
end

class ::Hash
  include Nydp::Helper
  def _nydp_get a    ; self[n2r a]           ; end
  def _nydp_set a, v ; self[n2r a] = n2r(v)  ; end
  def _nydp_keys     ; keys                  ; end
end
