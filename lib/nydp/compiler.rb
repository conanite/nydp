require 'nydp/cond'
require 'nydp/function_invocation'
require 'nydp/interpreted_function'
require 'nydp/literal'

module Nydp
  class Compiler
    extend Helper

    def self.compile expression, bindings, ns
      compile_expr expression, bindings, ns
    rescue StandardError => e
      raise Nydp::Error.new "failed to compile expression:\n#{expression._nydp_inspect}\n#{e.message}"
    end

    def self.compile_expr expression, bindings, ns
      # if expression.is_a? Nydp::Symbol
      if expression.is_a? ::Symbol
        SymbolLookup.build expression, bindings, ns
      elsif literal? expression
        Literal.build expression, bindings, ns
      elsif expression.is_a? Nydp::Pair
        compile_pair expression, bindings, ns
      else
        raise Nydp::Error.new "failed to compile unrecognised expression:\n#{expression._nydp_inspect}\nwhich is a #{expression.class}"
      end
    end

    def self.maybe_cons a, b
      Nydp::NIL.is?(a) ? b : cons(a, b)
    end

    def self.compile_each expr, bindings, ns
      if Nydp::NIL.is?(expr)
        expr
      elsif pair?(expr)
        maybe_cons compile(expr.car, bindings, ns), compile_each(expr.cdr, bindings, ns)
      else
        compile(expr, bindings, ns)
      end
    end

    def self.compile_pair expression, bindings, ns
      key = expression.car
      if sym?(key, :cond)
        Cond.build expression.cdr, bindings, ns # todo: replace with function? (cond x (fn () iftrue) (fn () iffalse)) -->> performance issues, creating two closures for every cond invocation
      elsif sym?(key, :quote)
        Literal.build expression.cadr, bindings, ns
      elsif sym?(key, :assign)
        Assignment.build expression.cdr, bindings, ns
      elsif sym?(key, :fn)
        InterpretedFunction.build expression.cadr, expression.cddr, bindings, ns
      else
        FunctionInvocation.build expression, bindings, ns
      end
    end
  end
end
