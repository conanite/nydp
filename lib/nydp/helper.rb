module Nydp
  R2NHELPERS = {
    ::Symbol   => ->(obj, ns) { Nydp::Symbol.mk(obj, ns)                            },
    Array      => ->(obj, ns) { Nydp::Pair.from_list obj.map { |o| Nydp.r2n o, ns } },
    String     => ->(obj, ns) { Nydp::StringAtom.new obj.to_s                       },
    NilClass   => ->(obj, ns) { Nydp.NIL                                            },
    FalseClass => ->(obj, ns) { Nydp.NIL                                            },
    TrueClass  => ->(obj, ns) { Nydp.T                                              },
  }

  def self.n2r nydp
    nydp.respond_to?(:to_ruby) ? nydp.to_ruby : nydp
  end

  def self.r2n ruby_obj, ns
    return ruby_obj._nydp_wrapper if ruby_obj.respond_to? :_nydp_wrapper

    rklass = ruby_obj.class
    R2NHELPERS.each do |hklass, proc|
      if rklass <= hklass
        return proc.call ruby_obj, ns
      end
    end

    ruby_obj
  end

  module Helper
    def n2r obj     ; Nydp.n2r obj     ; end
    def r2n obj, ns ; Nydp.r2n obj, ns ; end

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
