module Nydp
  class InvocationFailed < StandardError
  end

  module Invocation
    @@sig_counts = Hash.new { |h,k| h[k] = 0}

    class Base
      include Helper
      def initialize expr, source, sig=nil
        @expr, @source, @sig = expr, source, sig
      end

      def compile_to_ruby indent, srcs, opts={}
        ruby = if opts[:cando]
                 compile_do_expr_to_ruby indent, srcs
               end

        ruby ||= normal_compile_to_ruby indent, srcs
      end

      def compile_do_expr_to_ruby indent, srcs
        if @expr.car.is_a?(InterpretedFunction) && !@expr.cdr && @expr.car.can_do?
          @expr.car.compile_do_expr_to_ruby indent, srcs
        end
      end

      def normal_compile_to_ruby indent, srcs
        ra = @expr.map { |e| e.compile_to_ruby "#{indent}  ", srcs}.to_a
        fn = ra.shift

        src_expr = @expr.inspect.split(/\n/).join('\n')



        if ra.empty?
          "#{indent}  ##> #{src_expr}
#{fn}.
#{indent}  ##> #{src_expr}
#{indent}  _nydp_call()"
        else
          "#{indent}  ##> #{src_expr}
#{fn}.
#{indent}  ##> #{src_expr}
#{indent}  _nydp_call(#{ra.join(",\n")})"
        end
      end

#       def compile_to_ruby indent, srcs
#         ra = @expr.map { |e| e.compile_to_ruby "#{indent}  ", srcs}
#         fn = ra.shift

#         if ra.empty?
#           "#{indent}#{fn}._nydp_callable(#{@expr.first.to_s.inspect})._nydp_call()"
#         else
#           "#{indent}#{fn}._nydp_callable(#{@expr.first.to_s.inspect})._nydp_call(
# #{ra.join(",\n")}
# #{indent})"
#         end
#       end

      def handle e, f, invoker, *args
        case e
        when Nydp::Error, InvocationFailed
          raise
        else
          if e.is_a?(NoMethodError) && !f.respond_to?(invoker)
            raise InvocationFailed.new("#{f._nydp_inspect} is not a function: args were #{args._nydp_inspect} in #{source._nydp_inspect}")
          else
            msg  = args.map { |a| "  #{a._nydp_inspect}"}.join("\n")
            msg  =  "failed to execute invocation #{f._nydp_inspect}\n#{msg}"
            msg +=  "\nsource was #{source._nydp_inspect}"
            msg +=  "\nfunction name was #{source.car._nydp_inspect}"
            raise InvocationFailed.new msg
          end
        end
      end

      # TODO: speed up compilation by writing custom #lexical_reach for sig-based subclasses (when you know which elements of #expr are lexical symbols)
      def lexical_reach n
        @expr.map { |x| x.lexical_reach n}.max
      end

      def inspect ; "(" + @expr.map { |x| x._nydp_inspect }.join(' ') + ")" ; end
      def source  ; @source       ; end
      def to_s    ; source.to_s   ; end
    end

    class Invocation_1 < Invocation::Base
      def execute vm
        #        Invocation.sig @sig
        f = @expr.car.execute(vm)
        f.invoke_1 vm
      rescue StandardError => e
        handle e, f, :invoke_1
      rescue SystemStackError => e
        raise "stack overflow in #{@source}"
      end
    end

    class Invocation_2 < Invocation::Base
      def execute vm
        f = @expr.car.execute(vm)
        a = @expr.cadr.execute(vm)
        f.invoke_2 vm, a
#        Invocation.sig @sig
        # arg = vm.args.pop
        # f = vm.args.pop
        # f.invoke_2 vm, arg
      rescue StandardError => e
        handle e, f, :invoke_2, a
      rescue SystemStackError => e
        raise "stack overflow in #{@source}"
      end
    end

    class Invocation_3 < Invocation::Base
      def execute vm
        f = @expr.car.execute(vm)
        a0 = @expr.cadr.execute(vm)
        a1 = @expr.nth(2).execute(vm)
        f.invoke_3 vm, a0, a1
#        Invocation.sig @sig
        # arg_1 = vm.args.pop
        # arg_0 = vm.args.pop
        # f   = vm.args.pop
        # f.invoke_3 vm, arg_0, arg_1
      rescue StandardError => e
        handle e, f, :invoke_3, a0, a1
      rescue SystemStackError => e
        raise "stack overflow in #{@source}"
      end
    end

    class Invocation_4 < Invocation::Base
      def execute vm
        f = @expr.car.execute(vm)
        a0 = @expr.cadr.execute(vm)
        a1 = @expr.nth(2).execute(vm)
        a2 = @expr.nth(3).execute(vm)
        f.invoke_4 vm, a0, a1, a2
        # Invocation.sig @sig
        # arg_2 = vm.args.pop
        # arg_1 = vm.args.pop
        # arg_0 = vm.args.pop
        # f   = vm.args.pop
        # f.invoke_4 vm, arg_0, arg_1, arg_2
      rescue StandardError => e
        handle e, f, :invoke_4, a0, a1, a2
      rescue SystemStackError => e
        raise "stack overflow in #{@source}"
      end
    end

    class Invocation_N < Invocation::Base
      def initialize arg_count, expr, source
        super expr, source
        @arg_count = arg_count
      end

      def execute vm
        i = @expr.map { |x| x.execute(vm)}
        i.car.invoke vm, i.cdr

#        Invocation.sig @sig
        # args = vm.pop_args @arg_count
        # args.car.invoke vm, args.cdr
      rescue StandardError => e
        handle e, i.car, :invoke, i.cdr
      rescue SystemStackError => e
        raise "stack overflow in #{@source}"
      end
    end

    # TODO generate various Invocation_XXX classes on-demand instead of hand_coding them all up front
    SIGS = Set.new

    class Invocation_LEX < Invocation::Base
      SIGS << self.name
      def initialize expr, src
        super expr, src
        @sym = expr.car
      end

      def execute vm
#        Invocation.sig self.class.name
        @sym.value(vm.current_context).invoke_1 vm
      rescue StandardError => e
        handle e, @sym.value(vm.current_context), :invoke_1
      end
    end

    class Invocation_SYM < Invocation::Base
      SIGS << self.name
      def initialize expr, src
        super expr, src
        @sym = expr.car
      end

      def execute vm
#        Invocation.sig self.class.name
        @sym.value.invoke_1 vm
      rescue StandardError => e
        handle e, @sym.value, :invoke_1
      end
    end

    class Invocation_LEX_LEX < Invocation::Base
      SIGS << self.name
      def initialize expr, src
        super expr, src
        @lex0 = expr.car
        @lex1 = expr.cdr.car
      end

      def execute vm
#        Invocation.sig self.class.name
        fn = @lex0.value(vm.current_context)
        a0 = @lex1.value(vm.current_context)
        fn.invoke_2 vm, a0
      rescue StandardError => e
        handle e, fn, :invoke_2, a0
      end
    end

    class Invocation_SYM_NVB < Invocation::Base
      SIGS << self.name
      def initialize expr, src
        super expr, src
        @sym = expr.car
        @nvb1 = expr.cdr.car
      end

      def execute vm
#        Invocation.sig self.class.name
        fn = @sym.value
        a0 = @nvb1.execute(vm)
        fn.invoke_2 vm, a0
      rescue StandardError => e
        handle e, fn, :invoke_2, a0
      end
    end

    class Invocation_LEX_LIT < Invocation::Base
      SIGS << self.name
      def initialize expr, src
        super expr, src
        @lex0 = expr.car
        @lit1 = expr.cdr.car.expression
      end

      def execute vm
#        Invocation.sig self.class.name
        fn = @lex0.value(vm.current_context)
        fn.invoke_2 vm, @lit1
      rescue StandardError => e
        handle e, fn, :invoke_2, a0
      end
    end

    class Invocation_SYM_LEX < Invocation::Base
      SIGS << self.name
      def initialize expr, src
        super expr, src
        @sym = expr.car
        @lex = expr.cdr.car
      end

      def execute vm
#        Invocation.sig self.class.name
        a0 = @lex.value(vm.current_context)
        @sym.value.invoke_2 vm, a0
      rescue StandardError => e
        handle e, @sym.value, :invoke_2, a0
      end
    end

    class Invocation_SYM_LIT < Invocation::Base
      SIGS << self.name
      def initialize expr, src
        super expr, src
        @sym = expr.car
        @lit = expr.cdr.car.expression
      end

      def execute vm
#        Invocation.sig self.class.name
        @sym.value.invoke_2 vm, @lit
      rescue StandardError => e
        handle e, @sym.value, :invoke_2, @lit
      end
    end

    class Invocation_LEX_LEX_LEX < Invocation::Base
      SIGS << self.name
      def initialize expr, src
        super expr, src
        @lex_0 = expr.car
        @lex_1 = expr.cdr.car
        @lex_2 = expr.cdr.cdr.car
      end

      def execute vm
#        Invocation.sig self.class.name
        fn = @lex_0.value(vm.current_context)
        a0 = @lex_1.value(vm.current_context)
        a1 = @lex_2.value(vm.current_context)
        fn.invoke_3 vm, a0, a1
      rescue StandardError => e
        handle e, fn, :invoke_3, a0, a1
      end
    end

    class Invocation_SYM_LEX_LEX < Invocation::Base
      SIGS << self.name
      def initialize expr, src
        super expr, src
        @sym = expr.car
        @lex_0 = expr.cdr.car
        @lex_1 = expr.cdr.cdr.car
      end

      def execute vm
#        Invocation.sig self.class.name
        a0 = @lex_0.value(vm.current_context)
        a1 = @lex_1.value(vm.current_context)
        @sym.value.invoke_3 vm, a0, a1
      rescue StandardError => e
        handle e, @sym.value, :invoke_3, a0, a1
      end
    end

    class Invocation_SYM_NVB_LEX < Invocation::Base
      SIGS << self.name
      def initialize expr, src
        super expr, src
        @sym = expr.car
        @nvb_0 = expr.cdr.car
        @lex_1 = expr.cdr.cdr.car
      end

      def execute vm
#        Invocation.sig self.class.name
        a0 = @nvb_0.execute(vm)
        a1 = @lex_1.value(vm.current_context)
        @sym.value.invoke_3 vm, a0, a1
      rescue StandardError => e
        handle e, @sym.value, :invoke_3, a0, a1
      end
    end

    class Invocation_SYM_LEX_NVB < Invocation::Base
      SIGS << self.name
      def initialize expr, src
        super expr, src
        @sym = expr.car
        @lex_0 = expr.cdr.car
        @nvb_1 = expr.cdr.cdr.car
      end

      def execute vm
#        Invocation.sig self.class.name
        a0 = @lex_0.value(vm.current_context)
        a1 = @nvb_1.execute(vm)
        @sym.value.invoke_3 vm, a0, a1
      rescue StandardError => e
        handle e, @sym.value, :invoke_3, a0, a1
      end
    end

    class Invocation_SYM_LEX_LIT < Invocation::Base
      SIGS << self.name
      def initialize expr, src
        super expr, src
        @sym = expr.car
        @lex_0 = expr.cdr.car
        @lit_1 = expr.cdr.cdr.car.expression
      end

      def execute vm
#        Invocation.sig self.class.name
        a0 = @lex_0.value(vm.current_context)
        @sym.value.invoke_3 vm, a0, @lit_1
      rescue StandardError => e
        handle e, @sym.value, :invoke_3, a0, @lit_1
      end
    end

    class Invocation_SYM_LEX_LEX_LEX < Invocation::Base
      SIGS << self.name
      def initialize expr, src
        super expr, src
        @sym = expr.car
        @lex_0 = expr.cdr.car
        @lex_1 = expr.cdr.cdr.car
        @lex_2 = expr.cdr.cdr.cdr.car
      end

      def execute vm
#        Invocation.sig self.class.name
        a0 = @lex_0.value(vm.current_context)
        a1 = @lex_1.value(vm.current_context)
        a2 = @lex_2.value(vm.current_context)
        @sym.value.invoke_4 vm, a0, a1, a2
      rescue StandardError => e
        handle e, @sym.value, :invoke_4, a0, a1, a2
      end
    end

    class Invocation_SYM_LEX_LIT_LEX < Invocation::Base
      SIGS << self.name
      def initialize expr, src
        super expr, src
        @sym = expr.car
        @lex_0 = expr.cdr.car
        @lit_1 = expr.cdr.cdr.car.expression
        @lex_2 = expr.cdr.cdr.cdr.car
      end

      def execute vm
        # Invocation.sig self.class.name
        a0 = @lex_0.value(vm.current_context)
        a2 = @lex_2.value(vm.current_context)
        @sym.value.invoke_4 vm, a0, @lit_1, a2
      rescue StandardError => e
        handle e, @sym.value, :invoke_4, a0, @lit_1, a2
      end
    end

    class Invocation_SYM_LIT_LEX < Invocation::Base
      SIGS << self.name
      def initialize expr, src
        super expr, src
        @sym = expr.car
        @lit_0 = expr.cdr.car.expression
        @lex_1 = expr.cdr.cdr.car
      end

      def execute vm
#        Invocation.sig self.class.name
        a1 = @lex_1.value(vm.current_context)
        @sym.value.invoke_3 vm, @lit_0, a1
      rescue StandardError => e
        handle e, @sym.value, :invoke_3, @lit_0, a1
      end
    end

    class Invocation_SYM_LIT_LEX_LEX < Invocation::Base
      SIGS << self.name
      def initialize expr, src
        super expr, src
        @sym = expr.car
        @lit_0 = expr.cdr.car.expression
        @lex_1 = expr.cdr.cdr.car
        @lex_2 = expr.cdr.cdr.cdr.car
      end

      def execute vm
#        Invocation.sig self.class.name
        a1 = @lex_1.value(vm.current_context)
        a2 = @lex_2.value(vm.current_context)
        @sym.value.invoke_4 vm, @lit_0, a1, a2
      rescue StandardError => e
        handle e, @sym.value, :invoke_4, @lit_0, a1, a2
      end
    end
  end

  class FunctionInvocation
    extend Helper
    attr_accessor :function_instruction, :argument_instructions

    def lexical_reach n
      function_instruction.lexical_reach(n)
    end

    def compile_to_ruby indent, srcs, opts=nil
      ra = argument_instructions.map { |e| e.compile_to_ruby "#{indent}  ", srcs, cando: true }.to_a
      if ra.length == 1
        "#{indent}#{ra.shift}._nydp_call()"
      else
        "#{indent}#{ra.shift}._nydp_call(
#{ra.join(",\n")}
#{indent})"
      end
    end

    @@seen = { }

    def self.build expression, bindings, ns
      compiled   = Compiler.compile_each(expression, bindings, ns)
      # invocation_sig = compiled.map { |x| sig x }.join("_")

      # cname  = "Invocation_#{invocation_sig}"

      # exists = Invocation::SIGS.include? "Nydp::Invocation::#{cname}"
      # if exists
      #   return Nydp::Invocation.const_get(cname).new(compiled, expression)
      # end

      invocation = case expression.size
                        when 1
                          Invocation::Invocation_1.new(compiled, expression)
                        when 2
                          Invocation::Invocation_2.new(compiled, expression)
                        when 3
                          Invocation::Invocation_3.new(compiled, expression)
                        when 4
                          Invocation::Invocation_4.new(compiled, expression)
                        else
                          Invocation::Invocation_N.new(expression.size, compiled, expression)
                        end

      invocation

      # new invocation, compiled, expression, cname
    end

    def initialize function_instruction, argument_instructions, source, sig=nil
      @function_instruction, @argument_instructions, @source = function_instruction, argument_instructions, source
      @sig = sig
    end

    def execute vm
      ##      Invocation.sig @sig
      vm.push_ctx_instructions function_instruction
      vm.push_ctx_instructions argument_instructions
    end

    def inspect ; @function_instruction._nydp_inspect ; end
    def to_s    ; @source.to_s                        ; end
  end
end
