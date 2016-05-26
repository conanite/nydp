class Nydp::LexicalContext
  include Nydp::Helper
  attr_reader :names, :values, :parent

  def initialize parent
    @parent = parent
    @names  = []
    @values = []
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

  def at_index index
    values[index] || Nydp::NIL
  end

  def set name, value
    names  << name
    values << value
  end

  def set_args_1 names, arg
    if pair? names
      set names.car, arg
    elsif Nydp::NIL.isnt? names
      set names, cons(arg)
    end
  end

  def set_args_2 names, arg_0, arg_1
    if pair? names
      set names.car, arg_0
      set_args_1 names.cdr, arg_1
    elsif Nydp::NIL.isnt? names
      set names, cons(arg_0, cons(arg_1))
    end
  end

  def set_args_3 names, arg_0, arg_1, arg_2
    if pair? names
      set names.car, arg_0
      set_args_2 names.cdr, arg_1, arg_2
    elsif Nydp::NIL.isnt? names
      set names, cons(arg_0, cons(arg_1, cons(arg_2)))
    end
  end

  def set_index index, value
    values[index] = value
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
