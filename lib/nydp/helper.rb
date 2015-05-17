module Nydp
  module Helper
    def n2r nydp
      nydp.respond_to?(:to_ruby) ? nydp.to_ruby : nydp
    end

    def sym? expr, name
      expr.is_a?(Nydp::Symbol) && (expr.is? name)
    end

    def pair? expr
      expr.is_a?(Nydp::Pair)
    end

    def cons a, b=Nydp.NIL
      Nydp::Pair.new a, b
    end

    def list *args
      Nydp::Pair.from_list args
    end

    def sym name, ns
      Nydp::Symbol.mk name, ns
    end

    def literal? expr
      case expr
      when String, Float, Integer, Fixnum, Nydp.NIL, Nydp::Symbol, Nydp::StringAtom, Nydp::Truth, Nydp::Nil
        true
      else
        false
      end
    end
  end
end
