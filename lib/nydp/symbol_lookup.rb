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
          depth += 1
          bindings = bindings.cdr
        end
      end
      name
    end
  end
end
