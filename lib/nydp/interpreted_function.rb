require 'nydp/lexical_context'
require 'nydp/lexical_context_builder'
require 'nydp/closure'

module Nydp
  class PopArg
    # def self.execute vm ; vm.args.pop ; end
    def self.execute vm ; nil ; end
    def self.to_s       ; ""          ; end
    def self.inspect    ; "#pop_arg"  ; end
    def compile_to_ruby ; ""          ; end
  end

  class InterpretedFunction
    NIL = Nydp::NIL
    include Helper
    extend Helper

    attr_accessor :arg_names, :body, :context_builder

    def lexical_reach n
      body.map { |b| b.lexical_reach(n - 1)  }.max
    end

    def compile_to_ruby
      rubyargs = ["vm"]
      an = arg_names
      while (pair? an)
        rubyargs << "_arg_#{an.car.to_s._nydp_name_to_rb_name}=nil"
        an = an.cdr
      end

      if Nydp::NIL.isnt?(an)
        rubyargs << "_arg_#{an.to_s._nydp_name_to_rb_name}=nil"
      end

      code = "  (->(#{rubyargs.join ","}) {\n"
      body.each { |instr|
        if instr.respond_to? :compile_to_ruby
          code << "    " << instr.compile_to_ruby << "\n"
        else
          code << "    # NOCOMPILE : #{instr._nydp_inspect} (#{instr.class})"
        end
      }
      code << "  })"
    end

    def self.build arg_list, body, bindings, ns
      my_params = { }
      index_parameters arg_list, my_params
      body = compile_body body, cons(my_params, bindings), [], ns
      reach = body.map { |b| b.lexical_reach(-1)  }.max

      ifn_klass     = reach >= 0 ? InterpretedFunctionWithClosure : InterpretedFunctionWithoutClosure
      ifn           = ifn_klass.new
      ifn.arg_names = arg_list
      ifn.body      = body

      ifn.extend Nydp::LexicalContextBuilder.select arg_list
      ifn
    end

    def self.compile_body body_forms, bindings, instructions, ns
      instructions << Nydp::Compiler.compile(body_forms.car, bindings, ns)

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
        compile_body rest, bindings, instructions, ns
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
      "(fn #{arg_names._nydp_inspect} #{body.map { |b| b._nydp_inspect}.join(' ')})"
    end

    def run_body vm
      res = nil
      self.body.each { |x| res = x.execute(vm) }
      res
    end
  end

  class InterpretedFunctionWithClosure < InterpretedFunction
    def invoke_1 vm, ctx
      cc                 = vm.current_context
      vm.current_context = set_args_0(ctx)
      res                = run_body(vm)
      vm.current_context = cc
      res
      # vm.push_instructions self.body, set_args_0(ctx)
    end

    def invoke_2 vm, ctx, arg
      cc                 = vm.current_context
      vm.current_context = set_args_1(ctx, arg)
      res                = run_body(vm)
      vm.current_context = cc
      res
      # vm.push_instructions self.body, set_args_1(ctx, arg)
    end

    def invoke_3 vm, ctx, arg_0, arg_1
      cc                 = vm.current_context
      vm.current_context = set_args_2(ctx, arg_0, arg_1)
      res                = run_body(vm)
      vm.current_context = cc
      res
      # vm.push_instructions self.body, set_args_2(ctx, arg_0, arg_1)
    end

    def invoke_4 vm, ctx, arg_0, arg_1, arg_2
      cc                 = vm.current_context
      vm.current_context = set_args_3(ctx, arg_0, arg_1, arg_2)
      res                = run_body(vm)
      vm.current_context = cc
      res
      # vm.push_instructions self.body, set_args_3(ctx, arg_0, arg_1, arg_2)
    end

    def invoke vm, ctx, arg_values
      cc                 = vm.current_context
      vm.current_context = set_args(ctx, arg_values)
      res                = run_body(vm)
      vm.current_context = cc
      res
      # vm.push_instructions self.body, set_args(ctx, arg_values)
    end

    def execute vm
      Closure.new(self, vm.current_context)
      # vm.push_arg Closure.new(self, vm.current_context)
    end
  end

  class InterpretedFunctionWithoutClosure < InterpretedFunction
    def invoke_1 vm
      cc                 = vm.current_context
      vm.current_context = set_args_0(vm.current_context)
      res                = run_body(vm)
      vm.current_context = cc
      res
      # vm.push_instructions self.body, set_args_0(vm.current_context)
    end

    def invoke_2 vm, arg
      cc                 = vm.current_context
      vm.current_context = set_args_1(vm.current_context, arg)
      res                = run_body(vm)
      vm.current_context = cc
      res
      # vm.push_instructions self.body, set_args_1(vm.current_context, arg)
    end

    def invoke_3 vm, arg_0, arg_1
      cc                 = vm.current_context
      vm.current_context = set_args_2(vm.current_context, arg_0, arg_1)
      res                = run_body(vm)
      vm.current_context = cc
      res
      # vm.push_instructions self.body, set_args_2(vm.current_context, arg_0, arg_1)
    end

    def invoke_4 vm, arg_0, arg_1, arg_2
      cc                 = vm.current_context
      vm.current_context = set_args_3(vm.current_context, arg_0, arg_1, arg_2)
      res                = run_body(vm)
      vm.current_context = cc
      res
      # vm.push_instructions self.body, set_args_3(vm.current_context, arg_0, arg_1, arg_2)
    end

    def invoke vm, arg_values
      cc                 = vm.current_context
      vm.current_context = set_args(vm.current_context, arg_values)
      res                = run_body(vm)
      vm.current_context = cc
      res
      # vm.push_instructions self.body, set_args(vm.current_context, arg_values)
    end

    def execute vm
      # vm.push_arg self
      self
    end
  end
end
