require 'nydp/lexical_context'
require 'nydp/lexical_context_builder'
require 'nydp/closure'

module Nydp
  class PopArg
    def self.execute vm ; vm.args.pop ; end
    def self.to_s       ; ""         ; end
    def self.inspect    ; "#pop_arg" ; end
  end

  class InterpretedFunction
    NIL = Nydp::NIL
    include Helper
    extend Helper

    attr_accessor :arg_names, :body, :context_builder

    def invoke_1 vm, parent_context
      vm.push_instructions self.body, set_args_0(parent_context)
    end

    def invoke_2 vm, parent_context, arg
      vm.push_instructions self.body, set_args_1(parent_context, arg)
    end

    def invoke_3 vm, parent_context, arg_0, arg_1
      vm.push_instructions self.body, set_args_2(parent_context, arg_0, arg_1)
    end

    def invoke_4 vm, parent_context, arg_0, arg_1, arg_2
      vm.push_instructions self.body, set_args_3(parent_context, arg_0, arg_1, arg_2)
    end

    def invoke vm, parent_context, arg_values
      vm.push_instructions self.body, set_args(parent_context, arg_values)
    end

    def setup_context context, names, values
      if pair? names
        context.set names.car, values.car
        setup_context context, names.cdr, values.cdr
      elsif NIL != names
        context.set names, values
      end
    end

    def self.build arg_list, body, bindings
      my_params = { }
      index_parameters arg_list, my_params
      ifn = Nydp::InterpretedFunction.new
      ifn.arg_names = arg_list
      ifn.extend Nydp::LexicalContextBuilder.select arg_list
      ifn.body = compile_body body, cons(my_params, bindings), []
      ifn
    end

    def self.compile_body body_forms, bindings, instructions
      instructions << Nydp::Compiler.compile(body_forms.car, bindings)

      rest = body_forms.cdr
      if Nydp::NIL.is? rest
        return Pair.from_list(instructions)
      else
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

    def execute vm
      # TODO do not create a new Closure if this function does not refer to it
      #      - including top-level function definitions
      #      - and any other function that does not refer to any lexically-bound outer variable
      #      - for example (fn (x) (* x x)) in (map λx(* x x) things) does not need a closure, because
      #        the function does not refer to any lexical variable outside itself.
      vm.push_arg Closure.new(self, vm.current_context)
    end

    def nydp_type ; "fn" ; end
    def inspect   ; to_s ; end
    def to_s
      "(fn #{arg_names.inspect} #{body.map { |b| b.inspect}.join(' ')})"
    end
  end
end
