require 'nydp/context_symbol'

module Nydp
  class SymbolLookup
    extend Helper

    attr_reader :expression

    def initialize expression
      @expression = expression
    end

    def execute vm
      vm.push_arg expression.value vm.current_context
    end

    def assign value, context=nil
      @expression.assign value, context
    end

    def self.build name, bindings
      depth = 0
      while Nydp::NIL.isnt? bindings
        here = bindings.car
        if here.key? name
          binding_index = here[name]
          return new ContextSymbol.new(depth, name, binding_index)
        else
          depth += 1
          bindings = bindings.cdr
        end
      end
      new name
    end

    def to_s
      "#lookup:#{expression}:"
    end

    def inspect
      "#lookup_symbol:#{@expression.inspect}"
    end
  end
end
