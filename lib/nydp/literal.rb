module Nydp
  class Literal
    attr_reader :expression

    def initialize expression
      @expression = expression
    end

    def lisp_apply
      expression
    end

    def self.build expression, bindings
      new expression
    end

    def execute vm
      vm.push_arg self
    end

    def to_s
      expression
    end

    def inspect
      "literal:#{@expression}"
    end

    def coerce _
      [_, expression]
    end

    def > other
      other < expression
    end

    def < other
      other > expression
    end

    def == other
      other.is_a?(Literal) && (self.expression == other.expression)
    end
  end
end
