module Nydp
  class InvocationFailed < StandardError
  end

  class InvokeFunctionInstruction
    def initialize arg_count, source_expression
      @source_expression = source_expression
      @arg_count = arg_count
    end

    def execute vm
      args = vm.pop_args @arg_count
      args.car.invoke vm, args.cdr
    rescue Nydp::Error => ne
      raise ne
    rescue InvocationFailed => i_f
      raise i_f
    rescue Exception => e
      msg  =  "failed to execute invocation #{args.inspect}"
      msg +=  "\nsource was #{source.inspect}"
      msg +=  "\nfunction name was #{source.car.inspect}"
      i_f = InvocationFailed.new "#{msg}\n#{vm.error}#{e.message}"
      i_f.set_backtrace e.backtrace
      raise i_f
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
