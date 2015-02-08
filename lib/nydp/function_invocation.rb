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
      puts "failed to execute invocation #{args.to_s}"
      puts "source was #{source}"
      puts "function was #{source.car}"
      vm.error e
    end

    def inspect
      "#{self.class.name}:#{source}"
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
      new cons(InvokeFunctionInstruction.new(expression.size, expression)), Compiler.compile_each(expression, bindings), expression
    end

    def initialize function_instruction, argument_instructions, source
      @function_instruction, @argument_instructions, @source = function_instruction, argument_instructions, source
    end

    def execute vm
      vm.push_instructions @function_instruction,  vm.peek_context
      vm.push_instructions @argument_instructions, vm.peek_context
    end

    def inspect; "#function_invocation:#{to_s}"; end
    def to_s
      @source.to_s
    end
  end
end
