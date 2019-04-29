module Nydp
  class AssignmentInstruction
    attr_accessor :name

    def initialize name
      @name = name
    end

    def execute vm
      @name.assign vm.peek_arg, vm.current_context
    rescue
      raise "assigning #{@name.inspect}"
    end

    def to_s
      "#assign #{@name}"
    end
  end

  class Assignment
    include Helper

    def self.build args, bindings
      name = Compiler.compile args.car, bindings
      raise "can't assign to #{name.inspect} : expression was #{args}" unless name.respond_to?(:assign)
      value_expr = args.cdr.car
      Assignment.new name, Compiler.compile(value_expr, bindings), value_expr
    end

    def initialize name, value, value_src
      @name, @value, @value_src = name, value, value_src
      @instructions = cons(value, cons(AssignmentInstruction.new(name)))
    end

    def lexical_reach n
      [@name.lexical_reach(n), @value.lexical_reach(n)].max
    end

    def to_s
      "(assign #{@instructions.cdr.car.name} #{@value_src.inspect})"
    end

    def inspect; to_s ; end

    def execute vm
      vm.push_ctx_instructions @instructions
    rescue
      raise "assigning #{@value.inspect} to #{@name.inspect}"
    end
  end
end
