class Nydp::LexicalClosure
  attr_reader :values, :parent

  def initialize parent
    @parent = parent
    @values = { }
  end

  def nth n
    case n
    when 0
      self
    when -1
      raise "wrong nesting level"
    else
      parent.nth(n - 1)
    end
  end

  def at name
    values[name]
  end

  def set name, value
    values[name] = value
  end
end
