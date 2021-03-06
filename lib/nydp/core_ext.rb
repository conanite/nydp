class Object
  def _nydp_get     a ; raise "_nydp_get : not gettable: #{a._nydp_inspect} on #{self.class.name}" ; end
  def _nydp_set  a, v ; raise "_nydp_get : not settable: #{a._nydp_inspect} on #{self.class.name}" ; end
  def _nydp_keys      ; []      ; end
  def _nydp_wrapper   ; self    ; end
  def _nydp_inspect   ; inspect ; end
  def lexical_reach n ; n       ; end
  def to_ruby         ; self    ; end
end

class Method
  include Nydp::Converter
  def invoke_1 vm             ; vm.push_arg call._nydp_wrapper                            ; end
  def invoke_2 vm, a0         ; vm.push_arg call(n2r(a0))._nydp_wrapper                   ; end
  def invoke_3 vm, a0, a1     ; vm.push_arg call(n2r(a0), n2r(a1))._nydp_wrapper          ; end
  def invoke_4 vm, a0, a1, a2 ; vm.push_arg call(n2r(a0), n2r(a1), n2r(a2))._nydp_wrapper ; end
  def invoke   vm, args       ; vm.push_arg call(*(args.map { |a| n2r a}))._nydp_wrapper  ; end
end

class TrueClass
  def _nydp_inspect   ; 't'    ; end
  def assign       *_ ; self   ; end
  def nydp_type       ; :truth ; end
  def _nydp_get     a ; self   ; end
  def _nydp_set  a, v ; self   ; end
  def compile_to_ruby ; "true" ; end
end

class NilClass
  def _nydp_wrapper ; self ; end
  def car         ; self          ; end
  def cdr         ; self          ; end
  def size        ; 0             ; end
  def is?   other ; self.equal? other  ; end
  def isnt? other ; !self.equal? other ; end
  def + other     ; other         ; end
  def copy        ; self          ; end
  def assign *_   ; self          ; end
  def nydp_type   ; :nil          ; end
  def execute     vm ; vm.push_arg self ; end
  def _nydp_get    a ; self        ; end
  def _nydp_set a, v ; self        ; end
  # def each           ;                  ; end # nil behaves like an empty list
  def &        other ; self             ; end
  def |        other ; other            ; end
  def compile_to_ruby ; "nil"     ; end
end

class FalseClass
  def _nydp_wrapper ; Nydp::NIL ; end
end

# class TrueClass
#   def _nydp_wrapper ; Nydp::T ; end
# end

class ::Symbol
  # def _nydp_wrapper ; Nydp::FrozenSymbol.mk(self) ; end
  def _nydp_inspect
    _ins = to_s
    _nydp_untidy?(_ins) ? "|#{_ins.gsub(/\|/, '\|')}|" : _ins
  end

  def nydp_type  ; :symbol          ; end
  def execute vm ; vm.push_arg self ; end

  private

  def _nydp_untidy? s
    (s == "") || (s == nil) || (s =~ /[\s\|,\(\)"]/)
  end
end

class ::Date
  def _nydp_wrapper ; Nydp::Date.new self ; end
end

class ::Array
  def _nydp_wrapper ; Nydp::Pair.from_list map &:_nydp_wrapper   ; end
  def _nydp_inspect ; "[" + map(&:_nydp_inspect).join(" ") + "]" ; end
end

class ::Hash
  def _nydp_inspect ; "{" + map { |k,v| [k._nydp_inspect, v._nydp_inspect].join(" ")}.join(" ") + "}" ; end
end

class ::Object
  def to_ruby        ; self                       ; end
end

class ::String
  # def _nydp_wrapper  ; Nydp::StringAtom.new self  ; end
  def _nydp_name_to_rb_name ; self.gsub(/[-_\+\[\]\?\!\*\.\|#@\$%\^\&\(\)=\{\}\"\'\:\;~`<>\/\,\<\>]/) { |chr| "_#{chr.hex_ord}"}.to_sym ; end
  def as_method_name ; self.gsub(/-/, '_').to_sym ; end
  def nydp_type      ; :string                    ; end

  private

  def hex_ord ; ord.to_s(16).rjust(2, '0') ; end
end

class ::Hash
  include Nydp::Helper
  def _nydp_get a    ; self[n2r a]           ; end
  def _nydp_set a, v ; self[n2r a] = n2r(v)  ; end
  def _nydp_keys     ; keys                  ; end
end
