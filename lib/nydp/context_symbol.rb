module Nydp
  class ContextLookup0 ; def self.get_context ctx; ctx; end; end
  class ContextLookup1 ; def self.get_context ctx; ctx.parent; end; end
  class ContextLookup2 ; def self.get_context ctx; ctx.parent.parent; end; end
  class ContextLookup3 ; def self.get_context ctx; ctx.parent.parent.parent; end; end
  class ContextLookup4 ; def self.get_context ctx; ctx.parent.parent.parent.parent; end; end
  class ContextLookup5 ; def self.get_context ctx; ctx.parent.parent.parent.parent.parent; end; end
  class ContextLookup6 ; def self.get_context ctx; ctx.parent.parent.parent.parent.parent.parent; end; end
  class ContextLookup7 ; def self.get_context ctx; ctx.parent.parent.parent.parent.parent.parent.parent; end; end
  class ContextLookup8 ; def self.get_context ctx; ctx.parent.parent.parent.parent.parent.parent.parent.parent; end; end
  class ContextLookup9 ; def self.get_context ctx; ctx.parent.parent.parent.parent.parent.parent.parent.parent.parent; end; end
  class ContextLookup10; def self.get_context ctx; ctx.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent; end; end
  class ContextLookup11; def self.get_context ctx; ctx.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent; end; end
  class ContextLookup12; def self.get_context ctx; ctx.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent; end; end
  class ContextLookup13; def self.get_context ctx; ctx.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent; end; end
  class ContextLookup14; def self.get_context ctx; ctx.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent; end; end
  class ContextLookup15; def self.get_context ctx; ctx.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent; end; end
  class ContextLookup16; def self.get_context ctx; ctx.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent; end; end
  class ContextLookup17; def self.get_context ctx; ctx.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent; end; end
  class ContextLookup18; def self.get_context ctx; ctx.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent.parent; end; end
  class ContextLookupN
    def initialize depth ; @depth = depth  ; end
    def get_context  ctx ; ctx.nth(@depth) ; end
  end

  class ContextSymbol
    attr_accessor :depth, :name, :binding_index

    def initialize depth, name, binding_index
      @ctx_lookup = build_lookup depth
      @depth, @name, @binding_index = depth, name, binding_index
    end

    def execute vm
      vm.push_arg value vm.current_context
    end

    def get_context(context); @ctx_lookup.get_context context; end

    def value context
      get_context(context).at_index(binding_index)
    end

    def assign value, context
      get_context(context).set_index(binding_index, value)
    end

    def inspect; to_s; end
    def to_s
      "[#{depth}##{binding_index}]#{name}"
    end

    def build_lookup depth
      fast = Nydp.const_get "ContextLookup#{depth}" rescue nil
      return fast || ContextLookupN.new(depth)
    end
  end
end
