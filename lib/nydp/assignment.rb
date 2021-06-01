module Nydp
  class AssignmentInstruction
    attr_accessor :name

    def initialize name
      @name = name
    end

    def execute vm
      @name.assign vm.peek_arg, vm.current_context
    rescue
      raise "assigning #{@name._nydp_inspect}"
    end

    def to_s
      "#assign #{@name}"
    end
  end

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
      @instructions = cons(value, cons(AssignmentInstruction.new(name)))
    end

    def lexical_reach n
      [@name.lexical_reach(n), @value.lexical_reach(n)].max
    end

    def to_s
      "(assign #{@instructions.cdr.car.name} #{@value_src._nydp_inspect})"
    end

    def compile_to_ruby
      "(#{@name.compile_to_ruby} = #{@value.compile_to_ruby})"
    end

    def inspect; to_s ; end

    def execute vm
      vm.push_ctx_instructions @instructions
    rescue
      raise "assigning #{@value._nydp_inspect} to #{@name._nydp_inspect}"
    end
  end
end
