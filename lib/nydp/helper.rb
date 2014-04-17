module Nydp
  module Helper
    def sym? expr, name
      expr.is_a?(Nydp::Symbol) && (expr.is? name)
    end

    def pair? expr
      expr.is_a?(Nydp::Pair)
    end

    def cons a, b=NIL
      Nydp::Pair.new a, b
    end

    def literal? expr
      case expr
      when String, Float, Integer, Fixnum, Nydp::NIL, Nydp::Symbol
        true
      else
        false
      end
    end
  end
end
