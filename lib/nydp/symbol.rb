class Nydp::Symbol
  attr_accessor :name

  def initialize name
    @name = name.to_sym
  end

  def is? nm
    self.name == nm.to_sym
  end

  def value context=nil
    @value || Nydp.NIL
  end

  def self.mk name, ns
    name = name.to_sym
    sym = ns[name]
    unless sym
      sym = new(name)
      ns[name] = sym
    end
    sym
  end

  def self.find name, ns
    ns[name.to_sym]
  end

  def inspect
    "(sym #{name.to_s})"
  end

  def to_s
    name.to_s
  end

  def == other
    other.is_a?(Nydp::Symbol) && (self.name == other.name)
  end

  def assign value, context=nil
    @value = value
  end
end
