module Nydp::LexicalContextBuilder
  extend Nydp::Helper

  def self.const_missing(const)
    if const.to_s =~ /^B_\d+(_Rest)?$/
      name = const.to_s.split(/_/)
      size = name[1].to_i
      name[2] ? build_builder_rest_class(const, size) : build_builder_class(const, size)
      const_get const
    else
      super(const)
    end
  end

  def self.mklc nexpected
    (nexpected > 0) ? "lc = Nydp::LexicalContext.new lc\n    " : ""
  end

  def self.build_arg_names ngiven
    (["lc"] + (0...ngiven      ).map { |i| "arg_#{i}"}).join ", "
  end

  def self.build_set_args_n_method ngiven, nexpected
    setter_count = [ngiven, nexpected].min
    setters   = (0...setter_count).map { |i| "lc.at_#{i}= arg_#{i}"}
"  def set_args_#{ngiven} #{build_arg_names ngiven}
    #{mklc nexpected}#{setters.join "\n    "}
    lc
   rescue StandardError => e
     raise \"error in \#{self.class.name}#set_args_#{ngiven}\"
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
"  def set_args_#{ngiven} #{build_arg_names ngiven}
    #{mklc 1}#{setters.join "\n    "}
    #{rest_setter}
    lc
   rescue StandardError => e
     raise \"error in \#{self.class.name}#set_args_#{ngiven}\"
  end
"
  end

  def self.build_set_args_method nexpected
    setters   = (0...nexpected).map { |i| "lc.at_#{i}= args#{ ([".cdr"] * i).join }.car"}
"  def set_args lc, args
    #{mklc nexpected}#{setters.join "\n    "}
    lc
   rescue StandardError => e
     raise \"error in \#{self.class.name}#set_args\"
  end
"
  end

  def self.build_set_args_rest_method nexpected
    setters   = (0...nexpected).map { |i| "lc.at_#{i}= args#{ ([".cdr"] * i).join }.car"}
    rest_set  = "lc.at_#{nexpected}= args#{ ([".cdr"] *(nexpected)).join }"
"  def set_args lc, args
    #{mklc 1}#{setters.join "\n    "}
    #{rest_set}
    lc
   rescue StandardError => e
     raise \"error in \#{self.class.name}#set_args\"
  end
"
  end

  def self.define_module name, code
    const_set name.to_sym, Module.new { eval code }
  end

  def self.build_builder_class name, expected_arg_count
    n_methods = (0..3).map { |given| build_set_args_n_method given, expected_arg_count }
    x_method  = build_set_args_method expected_arg_count
    define_module name, "#{n_methods.join "\n"}\n#{x_method}"
  end

  def self.build_builder_rest_class name, proper_arg_count
    n_methods = (0..3).map { |given| build_set_args_n_rest_method given, proper_arg_count }
    x_method  = build_set_args_rest_method proper_arg_count
    define_module name, "#{n_methods.join "\n"}\n#{x_method}"
  end

  def self.select arg_names
    if pair?(arg_names)
      size   = arg_names.size
      proper = arg_names.proper?
    else
      size   = 0
      proper = Nydp::NIL.is? arg_names
    end
    const_get(proper ? :"B_#{size}" : :"B_#{size}_Rest")
  end
end
