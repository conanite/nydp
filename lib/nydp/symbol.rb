class Nydp::Symbol
  class Unbound < StandardError ; end
  EMPTY = :""
  attr_accessor :name

  def self.new name
    special(name.to_s.to_sym) || super
  end

  def initialize name
    name = name.to_s
    @name = name.to_sym
    raise "cannot be symbol : #{name.inspect}" if @name == :nil || @name == :t
    @inspection = "|#{name.gsub(/\|/, '\|')}|" if untidy(name)
  end

  def hash ; name.hash ; end # can't cache this, it seems to break when unmarshalling

  def untidy str
    (str == "") || (str == nil) || (str =~ /[\s\|,\(\)"]/)
  end

  def value context=nil
    # raise Unbound.new("unbound symbol: #{self._nydp_inspect}") if @value == nil
    @value
  end

  def compile_to_ruby
    "@ns_#{name.to_s._nydp_name_to_rb_name}"
  end

  def self.special name
    return Nydp::NIL if name == :nil
    return Nydp::T   if name == :t
    nil
  end

  def self.mk name, ns
    name = name.to_s.to_sym
    ns[name] ||= new(name)
  end

  def self.find name, ns ; ns[name.to_sym] ;  end

  def nydp_type           ; :symbol                  ; end
  def inspect             ; @inspection || name.to_s ; end
  def to_s                ; name.to_s                ; end
  def to_sym              ; name                     ; end
  def to_ruby             ; to_sym                   ; end
  def is?              nm ; self.name == nm.to_sym   ; end
  def >             other ; self.name > other.name   ; end
  def <             other ; self.name < other.name   ; end
  def <=>           other ; self.name <=> other.name ; end
  def assign value, _=nil ; @value = value           ; end
  def execute          vm ; vm.push_arg self.value   ; end

  def == other
    other.is_a?(Nydp::Symbol) && (self.name == other.name)
  end

  alias eql? ==
end

# class Nydp::FrozenSymbol < Nydp::Symbol
#   @@frozen = { }

#   def self.mk name
#     name = name.to_s.to_sym
#     @@frozen[name] ||= new(name)
#   end

#   def value _=nil
#     raise Unbound.new("frozen symbol: #{self._nydp_inspect}")
#   end

#   def assign v, _=nil
#     raise "can't assign to frozen: #{self._nydp_inspect}"
#   end
# end
