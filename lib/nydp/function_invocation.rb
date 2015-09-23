module Nydp
  class InvocationFailed < StandardError
  end

  module Invocation
    class Base
      include Helper
      def initialize source_expression
        @source_expression = source_expression
      end

      def handle e, f, args
        case e
        when Nydp::Error, InvocationFailed
          raise e
        else
          msg  =  "failed to execute invocation #{f.inspect} #{args.inspect}"
          msg +=  "\nsource was #{source.inspect}"
          msg +=  "\nfunction name was #{source.car.inspect}"
          i_f = InvocationFailed.new "#{msg}\n#{e.message}"
          i_f.set_backtrace e.backtrace
          raise i_f
        end
      end

      def inspect ; source.inspect     ; end
      def source  ; @source_expression ; end
      def to_s    ; source.to_s        ; end
    end

    class Invocation_1 < Invocation::Base
      def execute vm
        f = vm.pop_arg
        f.invoke_1 vm
      rescue Exception => e
        handle e, f, Nydp.NIL
      end
    end

    class Invocation_2 < Invocation::Base
      def execute vm
        arg = vm.pop_arg
        f   = vm.pop_arg
        f.invoke_2 vm, arg
      rescue Exception => e
        handle e, f, cons(arg)
      end
    end

    class Invocation_3 < Invocation::Base
      def execute vm
        arg_1 = vm.pop_arg
        arg_0 = vm.pop_arg
        f   = vm.pop_arg
        f.invoke_3 vm, arg_0, arg_1
      rescue Exception => e
        handle e, f, cons(arg_0, cons(arg_1))
      end
    end

    class Invocation_N < Invocation::Base
      def initialize arg_count, source_expression
        super source_expression
        @arg_count = arg_count
      end

      def execute vm
        args = vm.pop_args @arg_count
        args.car.invoke vm, args.cdr
      rescue Exception => e
        handle e, args.car, args.cdr
      end
    end
  end

  class FunctionInvocation
    extend Helper

    def self.build expression, bindings
      compiled   = Compiler.compile_each(expression, bindings)
      invocation = cons case expression.size
                        when 1
                          Invocation::Invocation_1.new(expression)
                        when 2
                          Invocation::Invocation_2.new(expression)
                        when 3
                          Invocation::Invocation_3.new(expression)
                        else
                          Invocation::Invocation_N.new(expression.size, expression)
                        end
      new invocation, compiled, expression
    end

    def initialize function_instruction, argument_instructions, source
      @function_instruction, @argument_instructions, @source = function_instruction, argument_instructions, source
    end

    def execute vm
      vm.push_instructions @function_instruction,  vm.peek_context
      vm.push_instructions @argument_instructions, vm.peek_context
    end

    def inspect ; @source.inspect ; end
    def to_s    ; @source.to_s    ; end
  end
end
