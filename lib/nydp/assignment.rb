module Nydp
  class Assignment
    include Helper

    def self.build args, bindings, ns
      name = Compiler.compile args.car, bindings, ns
      raise "can't assign to #{name._nydp_inspect} : expression was #{args}" unless name.respond_to?(:assign)
      value_expr = args.cdr.car
      Assignment.new name, Compiler.compile(value_expr, bindings, ns), value_expr
    end

    def initialize name, value, value_src
      @name, @value, @value_src = name, value, value_src
    end

    def lexical_reach n
      [@name.lexical_reach(n), @value.lexical_reach(n)].max
    end

    def to_s
      "(assign #{@name} #{@value_src._nydp_inspect})"
    end

    def compile_to_ruby indent, srcs, opts=nil
      "#{indent}(#{@name.compile_to_ruby "", srcs} = #{@value.compile_to_ruby indent, srcs})"
    end

    def inspect; to_s ; end

    def execute vm
      @name.assign @value.execute(vm), vm.current_context
    rescue
      raise "assigning #{@value._nydp_inspect} to #{@name._nydp_inspect}"
    end
  end
end
