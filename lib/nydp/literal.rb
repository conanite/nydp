module Nydp
  class Literal
    include Nydp::Helper
    attr_reader :expression

    def initialize expression
      @expression = expression
    end

    def self.build expression, bindings, ns
      new expression
    end

    def compile_to_ruby indent, srcs, opts=nil
      "#{indent}#{expression.compile_to_ruby "", srcs}"
    end

    def nydp_type ; :literal            ; end
    def inspect   ; @expression.inspect ; end
    def to_s      ; @expression.to_s    ; end
    def to_ruby   ; n2r @expression     ; end

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
