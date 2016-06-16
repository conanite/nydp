module Nydp::LexicalContextBuilder
  extend Nydp::Helper

  def self.build_set_args_n_method ngiven, nexpected
    setter_count = [ngiven, nexpected].min
    arg_names = (0...ngiven      ).map { |i| "arg_#{i}"}
    setters   = (0...setter_count).map { |i| "lc.at_#{i}= arg_#{i}"}
"  def set_args_#{ngiven} lc, #{arg_names.join ", "}
    #{setters.join "\n    "}
  end
"
  end

  def self.build_arg_conses arg_names, n
    if n == arg_names.size - 1
      "cons(#{arg_names[n]})"
    else
      "cons(#{arg_names[n]}, #{build_arg_conses(arg_names, n+1)})"
    end
  end

  def self.build_set_args_n_rest_method ngiven, nexpected
    setter_count = [ngiven, nexpected].min
    arg_names = (0...ngiven      ).map { |i| "arg_#{i}"}
    setters   = (0...setter_count).map { |i| "lc.at_#{i}= arg_#{i}"}
    if ngiven > setter_count
      rest_setter = "lc.at_#{nexpected}= #{build_arg_conses arg_names[setter_count..-1], 0}"
    end
"  def set_args_#{ngiven} lc, #{arg_names.join ", "}
    #{setters.join "\n    "}
    #{rest_setter}
  end
"
  end

  def self.build_set_args_method nexpected
    setters   = (0...nexpected).map { |i| "lc.at_#{i}= args#{ ([".cdr"] * i).join }.car"}
"  def set_args lc, args
    #{setters.join "\n    "}
  end
"
  end

  def self.build_set_args_rest_method nexpected
    setters   = (0...nexpected).map { |i| "lc.at_#{i}= args#{ ([".cdr"] * i).join }.car"}
    rest_set  = "lc.at_#{nexpected}= args#{ ([".cdr"] *(nexpected)).join }"
"  def set_args lc, args
    #{setters.join "\n    "}
    #{rest_set}
  end
"
  end

  def self.get_builder_class expected_arg_count
    name      = "B_#{expected_arg_count}"
    existing  = const_get(name) rescue nil
    return name if existing

    n_methods = (1..3).map { |given| build_set_args_n_method given, expected_arg_count }
    x_method  = build_set_args_method expected_arg_count
    klass     = <<KLASS
module #{name}
  def initialize_names names ; end

#{n_methods.join "\n"}
#{x_method}
end
KLASS

    eval klass
    name
  end

  def self.get_builder_rest_class proper_arg_count
    name      = "B_#{proper_arg_count}_Rest"
    existing  = const_get(name) rescue nil
    return name if existing

    n_methods = (1..3).map { |given| build_set_args_n_rest_method given, proper_arg_count }
    x_method  = build_set_args_rest_method proper_arg_count
    klass     = <<KLASS
module #{name}
  def initialize_names names ; end

#{n_methods.join "\n"}
#{x_method}
end
KLASS

    eval klass
    name
  end

  def self.select arg_names
    if pair?(arg_names)
      size   = arg_names.size
      proper = arg_names.proper?
    else
      size   = 0
      proper = Nydp::NIL.is? arg_names
    end

    if proper
      class_name = get_builder_class size
    else
      class_name = get_builder_rest_class size
    end

    self.const_get(class_name.to_sym)
  end
end
