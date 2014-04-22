module Nydp
  class ContextSymbol
    attr_accessor :depth, :name

    def initialize depth, name
      @depth, @name = depth, name
    end

    def value context
      context.nth(depth).at(name)
    end

    def assign value, context
      context.nth(depth).set(name, value)
    end

    def inspect; to_s; end
    def to_s
      "[#{depth}]#{name}"
    end
  end
end
