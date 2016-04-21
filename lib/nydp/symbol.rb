class Nydp::Symbol
  EMPTY = :""
  attr_accessor :name
  attr_reader   :hash

  def initialize name
    @name = name.to_sym
    @inspection = name.to_s
    @inspection = "|#{name}|" if untidy(@inspection)
    @hash       = name.hash
  end

  def untidy str
    (str == "") || (str == nil) || (str =~ /\s/)
  end

  def value context=nil
    raise "unbound symbol: #{self.inspect}" if @value == nil
    @value
  end

  def self.mk name, ns
    name = name.to_sym
    return Nydp.NIL if name == :nil
    return Nydp.T   if name == :t
    sym = ns[name]
    unless sym
      sym = new(name)
      ns[name] = sym
    end
    sym
  end


  def self.find name, ns ; ns[name.to_sym] ;  end

  def nydp_type  ; :symbol        ; end
  def inspect    ; @inspection    ; end
  def to_s       ; name.to_s      ; end
  def to_sym     ; name           ; end
  def to_ruby    ; to_sym         ; end
  def eql? other ; self == other  ; end
  def is? nm     ; self.name == nm.to_sym   ; end
  def > other    ; self.name > other.name   ; end
  def < other    ; self.name < other.name   ; end
  def <=> other  ; self.name <=> other.name ; end

  def == other
    other.is_a?(Nydp::Symbol) && (self.name == other.name)
  end

  def assign value, context=nil
    @value = value
  end
end
