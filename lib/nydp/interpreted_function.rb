require 'nydp/lexical_context'
require 'nydp/closure'

module Nydp
  class PopArg
    def self.execute vm
      vm.pop_arg
    end

    def self.to_s
      ""
    end

    def self.inspect
      "#pop_arg"
    end
  end

  class InterpretedFunction
    include Helper
    extend Helper

    attr_accessor :arg_names, :body

    def invoke vm, parent_context, arg_values
      lc = LexicalContext.new parent_context
      setup_context lc, arg_names, arg_values
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

    def inspect; to_s; end
    def to_s
      "(fn #{arg_names.to_s} #{body.map { |b| b.to_s}.join(' ')})"
    end
  end
end
