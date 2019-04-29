require 'nydp/lexical_context'
require 'nydp/lexical_context_builder'
require 'nydp/closure'

module Nydp
  class PopArg
    def self.execute vm ; vm.args.pop ; end
    def self.to_s       ; ""          ; end
    def self.inspect    ; "#pop_arg"  ; end
  end

  class InterpretedFunction
    NIL = Nydp::NIL
    include Helper
    extend Helper

    attr_accessor :arg_names, :body, :context_builder

    def lexical_reach n
      body.map { |b| b.lexical_reach(n - 1)  }.max
    end

    def self.build arg_list, body, bindings
      my_params = { }
      index_parameters arg_list, my_params
      body = compile_body body, cons(my_params, bindings), []
      reach = body.map { |b| b.lexical_reach(-1)  }.max

      ifn_klass     = reach >= 0 ? InterpretedFunctionWithClosure : InterpretedFunctionWithoutClosure
      ifn           = ifn_klass.new
      ifn.arg_names = arg_list
      ifn.body      = body

      ifn.extend Nydp::LexicalContextBuilder.select arg_list
      ifn
    end

    def self.compile_body body_forms, bindings, instructions
      instructions << Nydp::Compiler.compile(body_forms.car, bindings)

      rest = body_forms.cdr
      if Nydp::NIL.is? rest
        return Pair.from_list(instructions)
      else
        # PopArg is necessary because each expression pushes an arg onto the arg stack.
        # we only need to keep the arg pushed by the last expression in a function
        # so we need the following line in order to remove unwanted args from the stack.
        # Each expression at some executes vm.push_arg(thing)
        # TODO find a more intelligent way to do this, eg change the meaning of vm or of push_arg in the expression vm.push_arg(thing)
        instructions << PopArg
        compile_body rest, bindings, instructions
      end
    end

    def self.index_parameters arg_list, hsh
      if pair? arg_list
        index_parameters arg_list.car, hsh
        index_parameters arg_list.cdr, hsh
      elsif NIL != arg_list
        hsh[arg_list] = hsh.size
      end
    end

    def nydp_type ; "fn" ; end
    def inspect   ; to_s ; end
    def to_s
      "(fn #{arg_names.inspect} #{body.map { |b| b.inspect}.join(' ')})"
    end
  end

  class InterpretedFunctionWithClosure < InterpretedFunction
    def invoke_1 vm, ctx
      vm.push_instructions self.body, set_args_0(ctx)
    end

    def invoke_2 vm, ctx, arg
      vm.push_instructions self.body, set_args_1(ctx, arg)
    end

    def invoke_3 vm, ctx, arg_0, arg_1
      vm.push_instructions self.body, set_args_2(ctx, arg_0, arg_1)
    end

    def invoke_4 vm, ctx, arg_0, arg_1, arg_2
      vm.push_instructions self.body, set_args_3(ctx, arg_0, arg_1, arg_2)
    end

    def invoke vm, ctx, arg_values
      vm.push_instructions self.body, set_args(ctx, arg_values)
    end

    def execute vm
      vm.push_arg Closure.new(self, vm.current_context)
    end
  end

  class InterpretedFunctionWithoutClosure < InterpretedFunction
    def invoke_1 vm
      vm.push_instructions self.body, set_args_0(vm.current_context)
    end

    def invoke_2 vm, arg
      vm.push_instructions self.body, set_args_1(vm.current_context, arg)
    end

    def invoke_3 vm, arg_0, arg_1
      vm.push_instructions self.body, set_args_2(vm.current_context, arg_0, arg_1)
    end

    def invoke_4 vm, arg_0, arg_1, arg_2
      vm.push_instructions self.body, set_args_3(vm.current_context, arg_0, arg_1, arg_2)
    end

    def invoke vm, arg_values
      vm.push_instructions self.body, set_args(vm.current_context, arg_values)
    end

    def execute vm
      vm.push_arg self
    end
  end
end
