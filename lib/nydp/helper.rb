module Nydp
  module AutoWrap
    # include this and be sure to either override #_nydp_ok? or #_nydp_whitelist
    # #_nydp_whitelist should return a list of accessor (zero-arg) methods which are safe for nydp to call
    # #_nydp_procify should return a list of methods that can be exposed to script code.
    #
    # class Blub
    #   _nydp_procs << :blubme
    #   def blubme where, when
    #     puts "blubme #{where}, #{when}"
    #   end
    # end
    #
    # in nydp, if blub is an instance of Blub:
    #
    # (blub.blubme "here" "now")
    #
    # prints
    #
    # blubme here, now
    #
    def _nydp_wrapper                 ; self                                     ; end
    def _nydp_ok?              method ; _nydp_whitelist.include? method          ; end
    def _nydp_procify?         method ; _nydp_procs.include? method              ; end # override to allow returning Method instances for given method name
    def _nydp_get                 key ; _nydp_safe_send(key.to_s.as_method_name) ; end
    def to_ruby                       ; self                                     ; end
    def _nydp_safe_send meth, *args
      return send meth, *args if _nydp_ok?(meth)
      return method(meth)     if _nydp_procify?(meth)
    end
  end

  class Struct < ::Struct
    include AutoWrap
    def _nydp_whitelist ; members ; end
    def _nydp_procs     ; []      ; end
  end

  module Converter
    def n2r o ; o.respond_to?(:to_ruby) ? o.to_ruby : o ; end
    def r2n o ; o._nydp_wrapper                         ; end
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
      # expr.is_a?(Nydp::Symbol) && (expr.is? name)
      expr.is_a?(::Symbol) && (expr == name.to_sym)
    end

    def pair? expr
      expr.is_a?(Nydp::Pair)
    end

    def cons a=nil, b=nil
      Nydp::Pair.new a, b
    end

    def list *args
      Nydp::Pair.from_list args
    end

    def sym name, ns
      # Nydp::Symbol.mk name, ns
      name.to_s.to_sym
    end

    def literal? expr
      case expr
      # when String, Float, Integer, Integer, Symbol, Nydp::Truth, Nydp::Nil
      # when String, Float, Integer, Integer, Symbol, Nydp::Truth, NilClass
      when String, Float, Integer, Integer, Symbol, TrueClass, NilClass
        true
      else
        false
      end
    end
  end
end
