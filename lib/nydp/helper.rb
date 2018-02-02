module Nydp
  module AutoWrap
    def _nydp_wrapper ; self ; end
    def to_ruby       ; self ; end
  end

  module Converter
    def n2r         o ; o.respond_to?(:to_ruby) ? o.to_ruby : o ; end
    def r2n o, ns=nil ; o._nydp_wrapper                         ; end
  end

  extend Converter

  module Helper
    include Converter

    def sig klass
      case klass
      when Nydp::Symbol              ; "SYM"
      when Nydp::ContextSymbol       ; "LEX"
      when Nydp::Literal             ; "LIT"
      when Nydp::FunctionInvocation  ; "NVK"
      when Nydp::Invocation::Base    ; "NVB"
      when Nydp::InterpretedFunction ; "IFN"
      when Nydp::Cond                ; "CND"
      when Nydp::CondBase            ; "CND"
      when Nydp::Assignment          ; "ASN"
      else ; raise "no sig for #{klass.class.name}"
      end
    end

    def sym? expr, name
      expr.is_a?(Nydp::Symbol) && (expr.is? name)
    end

    def pair? expr
      expr.is_a?(Nydp::Pair)
    end

    def cons a, b=Nydp::NIL
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
      when String, Float, Integer, Fixnum, Nydp::Symbol, Nydp::StringAtom, Nydp::Truth, Nydp::Nil
        true
      else
        false
      end
    end
  end
end
