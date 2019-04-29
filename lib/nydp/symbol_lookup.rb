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

    def self.build name, original_bindings
      effective_bindings = skip_empty original_bindings
      depth    = 0
      while NIL != effective_bindings
        here = effective_bindings.car
        if here.key? name
          binding_index = here[name]
          return ContextSymbol.build(depth, name, binding_index, original_bindings.index_of(here))
        else
          depth += 1
          effective_bindings = skip_empty effective_bindings.cdr
        end
      end
      name
    end
  end
end
