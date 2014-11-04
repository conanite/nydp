module Nydp
  class InvokeFunctionInstruction
    def initialize arg_count, source_expression
      @source_expression = source_expression
      @arg_count = arg_count
    end

    def execute vm
      args = vm.pop_args @arg_count
      args.car.invoke vm, args.cdr
    rescue Exception => e
      puts "failed to execute fn #{args.inspect}"
      puts "source was #{source}"
      puts "function was #{args.car.inspect}"
      vm.error e
    end

    def inspect
      to_s
    end

    def source
      @source_expression
    end

    def to_s
      source
    end
  end

  class FunctionInvocation
    extend Helper

    def self.build expression, bindings
      new cons(InvokeFunctionInstruction.new(expression.size, expression)), Compiler.compile_each(expression, bindings)
    end

    def initialize function_instruction, argument_instructions
      @function_instruction, @argument_instructions = function_instruction, argument_instructions
    end

    def execute vm
      vm.push_instructions @function_instruction,  vm.peek_context
      vm.push_instructions @argument_instructions, vm.peek_context
    end

    def inspect; to_s; end
    def to_s
      "#function_invocation:#{@function_instruction.car.source} #{@argument_instructions.inspect}"
    end
  end
end
