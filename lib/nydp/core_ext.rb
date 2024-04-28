class Object
  def _nydp_get     a ; raise "_nydp_get : not gettable: #{a._nydp_inspect} on #{self.class.name}" ; end
  def _nydp_set  a, v ; raise "_nydp_get : not settable: #{a._nydp_inspect} on #{self.class.name}" ; end
  def _nydp_keys      ; []      ; end
  def _nydp_wrapper         ; self          ; end
  def _nydp_inspect         ; inspect       ; end
  def _nydp_to_s            ; to_s          ; end
  def _nydp_compact_inspect ; _nydp_inspect ; end
  def to_ruby               ; self          ; end
  def compile_to_ruby indent, srcs, opts=nil ; "#{indent}#{inspect}" ; end
end

class Method
  include Nydp::Converter
  def _nydp_call *args ; (call *(rubify args))._nydp_wrapper ; end
end

class Proc
  alias _nydp_call call
end

class TrueClass
  def _nydp_inspect   ; 't'    ; end
  def assign       *_ ; self   ; end
  def nydp_type       ; :truth ; end
  def _nydp_get     a ; self   ; end
  def _nydp_set  a, v ; self   ; end
  def _nydp_to_s      ; "t"    ; end
  def compile_to_ruby indent, srcs, opts=nil ; "#{indent}true" ; end
end

class CantCallNil < NoMethodError
end

class NilClass
  def car            ; self               ; end
  def cdr            ; self               ; end
  def size           ; 0                  ; end
  def is?      other ; self.equal? other  ; end
  def isnt?    other ; !self.equal? other ; end
  def +        other ; other              ; end
  def copy           ; self               ; end
  def assign      *_ ; self               ; end
  def nydp_type      ; :nil               ; end
  def _nydp_get    a ; self               ; end
  def _nydp_set a, v ; self               ; end
  def &        other ; self               ; end
  def |        other ; other              ; end
  def _nydp_call  *_ ; raise CantCallNil  ; end
  def compile_to_ruby i, s, o=nil ; "#{i}nil"      ; end
end

class FalseClass
  def _nydp_wrapper ; nil ; end
end

class ::Symbol
  def _nydp_inspect
    _ins = to_s
    _nydp_untidy?(_ins) ? "|#{_ins.gsub(/\|/, '\|')}|" : _ins
  end

  def nydp_type  ; :symbol ; end
  # def execute vm ; self    ; end

  alias :inspect_before_nydp :inspect
  def inspect
    if self == :"#="
      ':"#="'
    else
      inspect_before_nydp
    end
  end

  private

  def _nydp_untidy? s
    (s == "") || (s == nil) || (s =~ /[\s\|,\(\)"]/)
  end
end

class ::Date
  def _nydp_get key ; _nydp_date.lookup key, self           ; end
  def _nydp_date    ; @__nydp_date ||= Nydp::Date.new(self) ; end
  def nydp_type     ; :date                                 ; end
end

class ::Time
  @@wl = Set.new %i{ year month day hour min sec }
  def _nydp_time_get key ; send(key) if @@wl.include?(key) ; end
  def _nydp_get      key ; _nydp_time_get(key.to_s.to_sym) ; end
  def nydp_type          ; :time                           ; end
end

class ::Array
  def _nydp_wrapper ; Nydp::Pair.from_list map &:_nydp_wrapper   ; end
  def _nydp_inspect ; "[" + map(&:_nydp_inspect).join(" ") + "]" ; end
end

class ::String
  # _hex_ord only works for characters whose #ord is < 256, ie #bytes returns a single-element array
  # this should allow for two-way conversion of names containing the characters in the regexp
  # even though we don't use two-way conversion anywhere just yet
  def _nydp_name_to_rb_name ; self.gsub(/[\x00-\x2F\x3A-\x40\x5B-\x60\x7B-\x7F]/) { |chr| "_#{chr._hex_ord}"}.to_sym ; end
  def as_method_name ; self.gsub(/-/, '_').to_sym ; end
  def nydp_type      ; :string                    ; end
  def _hex_ord       ; ord.to_s(16).rjust(2, '0') ; end
  def car            ; self[0]                    ; end
  def cdr            ; self[1..-1]                ; end
end

class ::Hash
  include Nydp::Helper
  def _nydp_get a    ; self[a]._nydp_wrapper     ; end
  def _nydp_set a, v ; self[a] = v               ; end
  def _nydp_keys     ; keys                      ; end
  def _nydp_inspect  ; "{" + map { |k,v| [k._nydp_inspect, v._nydp_inspect].join(" ")}.join(" ") + "}" ; end
  def nydp_type      ; :hash                     ; end
end
