class Nydp::LexicalContext
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

  def to_s_with_indent str
    me = @values.map { |k, v|
      [str, k, "=>", v].join ' '
    }.join "\n"
    me + (parent ? parent.to_s_with_indent("  #{str}") : '')
  end

  def to_s
    to_s_with_indent ''
  end
end
