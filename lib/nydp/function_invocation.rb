module Nydp
  class InvocationFailed < StandardError
  end

  module Invocation
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

      Invocation::Base.new(compiled, expression)
    end

    def initialize function_instruction, argument_instructions, source, sig=nil
      @function_instruction, @argument_instructions, @source = function_instruction, argument_instructions, source
      @sig = sig
    end

    def inspect ; @function_instruction._nydp_inspect ; end
    def to_s    ; @source.to_s                        ; end
  end
end
