require 'nydp/lexical_context'
require 'nydp/closure'

module Nydp
  class InterpretedFunction
    include Helper
    extend Helper

    attr_accessor :arg_names, :body

    def invoke vm, parent_context, arg_values
      lc = LexicalContext.new parent_context
      setup_context lc, arg_names, arg_values
      vm.push_context lc
      vm.push_instructions self.body
    end

    def setup_context context, names, values
      if pair? names
        context.set names.car, values.car
        setup_context context, names.cdr, values.cdr
      elsif NIL.isnt? names
        context.set names, values
      end
    end

    def self.build arg_list, body, bindings
      my_params = { }
      index_parameters arg_list, my_params
      puts "indexed params: #{my_params.inspect}"
      ifn = Nydp::InterpretedFunction.new
      ifn.arg_names = arg_list
      ifn.body = Nydp::Compiler.compile_each body, cons(my_params, bindings)
      ifn
    end

    def self.index_parameters arg_list, hsh
      return if Nydp::NIL.is?(arg_list)

      if pair? arg_list
        index_parameters arg_list.car, hsh
        index_parameters arg_list.cdr, hsh
      else
        hsh[arg_list] = hsh.size
      end
    end

    def execute vm
      vm.push_arg Closure.new(self, vm.peek_context)
    end

    def to_s
      "(fn #{arg_names} #{body})"
    end
  end
end
