module Nydp
  class InvokeFunctionInstruction
    def initialize arg_count
      @arg_count = arg_count
    end

    def execute vm
      args = vm.pop_args @arg_count
      args.car.invoke vm, args.cdr
    end

    def inspect
      to_s
    end

    def to_s
      "(#invoke #{@arg_count - 1})"
    end
  end

  class FunctionInvocation
    extend Helper

    def self.build expression, bindings
      new cons(InvokeFunctionInstruction.new(expression.size)), Compiler.compile_each(expression, bindings)
    end

    def initialize function_instruction, argument_instructions
      @function_instruction, @argument_instructions = function_instruction, argument_instructions
    end

    def execute vm
      vm.push_instructions @function_instruction
      vm.push_instructions @argument_instructions
    end

    def inspect; to_s; end
    def to_s
      "#function_invocation:#{@argument_instructions.inspect}"
    end
  end
end
