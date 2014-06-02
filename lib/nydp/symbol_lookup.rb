require 'nydp/context_symbol'

module Nydp
  class SymbolLookup
    extend Helper

    attr_reader :expression

    def initialize expression
      @expression = expression
    end

    def execute vm
      vm.push_arg expression.value vm.peek_context
    end

    def self.build name, bindings
      depth = 0
      while Nydp.NIL.isnt? bindings
        here = bindings.car
        if here.key? name
          return new ContextSymbol.new(depth, name)
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
