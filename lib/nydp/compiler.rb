require 'nydp/cond'
require 'nydp/function_invocation'
require 'nydp/interpreted_function'
require 'nydp/literal'

module Nydp
  class Compiler
    extend Helper

    def self.compile expression, bindings
      compile_expr expression, bindings
    rescue Exception => e
      new_msg = "failed to compile expression #{expression.inspect},\nerror was #{e.message}"
      raise $!, new_msg, $!.backtrace
    end

    def self.compile_expr expression, bindings
      if expression.is_a? Nydp::Symbol
        SymbolLookup.build expression, bindings
      elsif literal? expression
        Literal.build expression, bindings
      elsif expression.is_a? Nydp::Pair
        compile_pair expression, bindings
      end
    end

    def self.maybe_cons a, b
      Nydp::NIL.is?(a) ? b : cons(a, b)
    end

    def self.compile_each expr, bindings
      if Nydp::NIL.is?(expr)
        expr
      elsif pair?(expr)
        maybe_cons compile(expr.car, bindings), compile_each(expr.cdr, bindings)
      else
        compile(expr, bindings)
      end
    end

    def self.compile_pair expression, bindings
      key = expression.car
      if sym?(key, :cond)
        Cond.build expression.cdr, bindings
      elsif sym?(key, :quote)
        Literal.build expression.cadr, bindings
      elsif sym?(key, :assign)
        Assignment.build expression.cdr, bindings
      elsif sym?(key, :fn)
        InterpretedFunction.build expression.cadr, expression.cddr, bindings
      else
        FunctionInvocation.build expression, bindings
      end
    end
  end
end
