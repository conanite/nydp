class Nydp::Symbol
  attr_accessor :name, :value

  def initialize name
    @name = name.to_sym
  end

  def is? nm
    self.name == nm.to_sym
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
    "Symbol:#{name.inspect}"
  end

  def to_s
    name.to_s
  end

  def assign value
    self.value = value
  end
end
