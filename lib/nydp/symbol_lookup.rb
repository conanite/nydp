require 'nydp/context_symbol'

module Nydp
  class SymbolLookup
    extend Helper

    def self.skip_empty bindings
      while (NIL != bindings) && bindings.car.empty?
        bindings = bindings.cdr
      end
      bindings
    end

    def self.build name, bindings
      bindings = skip_empty bindings
      depth = 0
      while NIL != bindings
        here = bindings.car
        if here.key? name
          binding_index = here[name]
          return ContextSymbol.build(depth, name, binding_index)
        else
          depth += 1
          bindings = skip_empty bindings.cdr
        end
      end
      name
    end
  end
end
