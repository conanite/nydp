module Nydp
  class Assignment
    include Helper

    def self.build args, bindings, ns
      name = Compiler.compile args.car, bindings, ns
      raise "can't assign to #{name._nydp_inspect} : expression was #{args}" unless name.respond_to?(:assign)
      value_expr = args.cdr.car
      Assignment.new name, Compiler.compile(value_expr, bindings, ns), args
    end

    def initialize name, value, src
      @name, @value, @src = name, value, src
    end

    def to_s
      "(assign #{@src.car} #{@src.cdr.car})"
    end

    def compile_to_ruby indent, srcs, opts=nil
      "#{indent}##> #{to_s.split(/\n/).join('\n')}\n" +
        "#{indent}(#{@name.compile_to_ruby "", srcs} =\n" +
        "#{indent}#{@value.compile_to_ruby indent, srcs})"
    end

    def inspect; to_s ; end
  end
end
