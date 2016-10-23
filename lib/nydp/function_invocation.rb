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
        f = vm.args.pop
        f.invoke_1 vm
      rescue Exception => e
        handle e, f, Nydp::NIL
      end
    end

    class Invocation_2 < Invocation::Base
      def execute vm
        arg = vm.args.pop
        f = vm.args.pop

        f.invoke_2 vm, arg
      rescue Exception => e
        handle e, f, cons(arg)
      end
    end

    class Invocation_3 < Invocation::Base
      def execute vm
        arg_1 = vm.args.pop
        arg_0 = vm.args.pop
        f   = vm.args.pop
        f.invoke_3 vm, arg_0, arg_1
      rescue Exception => e
        handle e, f, cons(arg_0, cons(arg_1))
      end
    end

    class Invocation_4 < Invocation::Base
      def execute vm
        arg_2 = vm.args.pop
        arg_1 = vm.args.pop
        arg_0 = vm.args.pop
        f   = vm.args.pop
        f.invoke_4 vm, arg_0, arg_1, arg_2
      rescue Exception => e
        handle e, f, cons(arg_0, cons(arg_1, cons(arg_2)))
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

    # TODO generate various Invocation_XXX classes on-demand instead of hand_coding them all up front
    class Invocation_LEX < Invocation::Base
      def initialize expr, src
        super src
        @sym = expr.car
      end

      def execute vm
        @sym.value(vm.current_context).invoke_1 vm
      rescue Exception => e
        handle e, @sym.value(vm.current_context), Nydp::NIL
      end
    end

    class Invocation_SYM < Invocation::Base
      def initialize expr, src
        super src
        @sym = expr.car
      end

      def execute vm
        @sym.value.invoke_1 vm
      rescue Exception => e
        handle e, @sym.value, Nydp::NIL
      end
    end

    class Invocation_LEX_LEX < Invocation::Base
      def initialize expr, src
        super src
        @lex0 = expr.car
        @lex1 = expr.cdr.car
      end

      def execute vm
        fn = @lex0.value(vm.current_context)
        a0 = @lex1.value(vm.current_context)
        fn.invoke_2 vm, a0
      rescue Exception => e
        handle e, fn, cons(a0)
      end
    end

    class Invocation_SYM_LEX < Invocation::Base
      def initialize expr, src
        super src
        @sym = expr.car
        @lex = expr.cdr.car
      end

      def execute vm
        fn = @sym.value
        a0 = @lex.value(vm.current_context)
        fn.invoke_2 vm, a0
      rescue Exception => e
        handle e, fn, cons(a0)
      end
    end

    class Invocation_LEX_LEX_LEX < Invocation::Base
      def initialize expr, src
        super src
        @lex_0 = expr.car
        @lex_1 = expr.cdr.car
        @lex_2 = expr.cdr.cdr.car
      end

      def execute vm
        fn = @lex_0.value(vm.current_context)
        a0 = @lex_1.value(vm.current_context)
        a1 = @lex_2.value(vm.current_context)
        fn.invoke_3 vm, a0, a1
      rescue Exception => e
        handle e, fn, cons(a0, cons(a1))
      end
    end

    class Invocation_SYM_LEX_LEX < Invocation::Base
      def initialize expr, src
        super src
        @sym = expr.car
        @lex_0 = expr.cdr.car
        @lex_1 = expr.cdr.cdr.car
      end

      def execute vm
        fn = @sym.value
        a0 = @lex_0.value(vm.current_context)
        a1 = @lex_1.value(vm.current_context)
        fn.invoke_3 vm, a0, a1
      rescue Exception => e
        handle e, fn, cons(a0, cons(a1))
      end
    end
  end

  class FunctionInvocation
    extend Helper
    attr_accessor :function_instruction, :argument_instructions

    def self.sig klass
      case klass
      when Nydp::Symbol              ; "SYM"
      when Nydp::ContextSymbol       ; "LEX"
      when Nydp::Literal             ; "LIT"
      when Nydp::FunctionInvocation  ; "NVK"
      when Nydp::Invocation::Base    ; "NVB"
      when Nydp::InterpretedFunction ; "IFN"
      when Nydp::Cond                ; "CND"
      when Nydp::Assignment          ; "ASN"
      else ; raise "no sig for #{klass.class.name}"
      end
    end
    def self.build expression, bindings
      compiled   = Compiler.compile_each(expression, bindings)
      invocation_sig = compiled.map { |x| sig x }.join("_")

      cname  = "Invocation_#{invocation_sig}"
      iclass = Nydp::Invocation.const_get(cname) rescue nil
      if iclass
        # puts "found #{cname}"
        return iclass.new(compiled, expression)
      end

      invocation = cons case expression.size
                        when 1
                          Invocation::Invocation_1.new(expression)
                        when 2
                          Invocation::Invocation_2.new(expression)
                        when 3
                          Invocation::Invocation_3.new(expression)
                        when 4
                          Invocation::Invocation_4.new(expression)
                        else
                          Invocation::Invocation_N.new(expression.size, expression)
                        end
      new invocation, compiled, expression
    end

    def initialize function_instruction, argument_instructions, source
      @function_instruction, @argument_instructions, @source = function_instruction, argument_instructions, source
    end

    def execute vm
      vm.instructions.push function_instruction
      vm.contexts    .push vm.current_context
      vm.instructions.push argument_instructions
      vm.contexts    .push vm.current_context
    end

    def inspect ; @source.inspect ; end
    def to_s    ; @source.to_s    ; end
  end
end
