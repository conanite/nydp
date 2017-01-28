require 'nydp/context_symbol'

module Nydp
  class SymbolLookup
    extend Helper

    def self.build name, bindings
      depth = 0
      while Nydp::NIL.isnt? bindings
        here = bindings.car
        if here.key? name
          binding_index = here[name]
          return ContextSymbol.build(depth, name, binding_index)
        else
          depth += 1 # TODO don't increment depth for zero_arg functions, we won't make a Closure or LexicalContext for these
                     # TODO see also InterpretedFunction
          bindings = bindings.cdr
        end
      end
      name
    end
  end
end
