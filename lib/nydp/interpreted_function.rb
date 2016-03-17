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
    include Helper
    extend Helper

    attr_accessor :arg_names, :body, :context_builder

    def invoke_1 vm, parent_context
      vm.push_instructions self.body, LexicalContext.new(parent_context)
    end

    def invoke_2 vm, parent_context, arg
      lc = LexicalContext.new parent_context
      set_args_1 lc, arg
      vm.push_instructions self.body, lc
    end

    def invoke_3 vm, parent_context, arg_0, arg_1
      lc = LexicalContext.new parent_context
      set_args_2 lc, arg_0, arg_1
      vm.push_instructions self.body, lc
    end

    def invoke_4 vm, parent_context, arg_0, arg_1, arg_2
      lc = LexicalContext.new parent_context
      set_args_3 lc, arg_0, arg_1, arg_2
      vm.push_instructions self.body, lc
    end

    def invoke vm, parent_context, arg_values
      lc = LexicalContext.new parent_context
      set_args lc, arg_values
      vm.push_instructions self.body, lc
    end

    def setup_context context, names, values
      if pair? names
        context.set names.car, values.car
        setup_context context, names.cdr, values.cdr
      elsif Nydp.NIL.isnt? names
        context.set names, values
      end
    end

    def self.build arg_list, body, bindings
      my_params = { }
      index_parameters arg_list, my_params
      ifn = Nydp::InterpretedFunction.new
      ifn.arg_names = arg_list
      ifn.extend Nydp::LexicalContextBuilder.select arg_list
      ifn.initialize_names arg_list
      ifn.body = compile_body body, cons(my_params, bindings), []
      ifn
    end

    def self.compile_body body_forms, bindings, instructions
      instructions << Nydp::Compiler.compile(body_forms.car, bindings)

      rest = body_forms.cdr
      if Nydp.NIL.is? rest
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
      elsif Nydp.NIL.isnt? arg_list
        hsh[arg_list] = hsh.size
      end
    end

    def execute vm
      vm.push_arg Closure.new(self, vm.peek_context)
    end

    def nydp_type ; "fn" ; end
    def inspect   ; to_s ; end
    def to_s
      "(fn #{arg_names.inspect} #{body.map { |b| b.inspect}.join(' ')})"
    end
  end
end
