require 'nydp/function_invocation'
require 'nydp/literal'

module Nydp
  class Compiler
    extend Helper

    def self.compile expression
      if expression.is_a? Nydp::Symbol
        SymbolLookup.build expression
      elsif literal? expression
        Literal.build expression
      elsif expression.is_a? Nydp::Pair
        puts "compiling #{expression}"
        compile_pair expression
      end
    end

    def self.compile_each expr
      if NIL.is?(expr)
        expr
      elsif pair?(expr)
        cons compile(expr.car), compile_each(expr.cdr)
      else
        compile(expr)
      end
    end

    def self.compile_pair expression
      key = expression.car
      if sym?(key, :if)
        Cond.build expression.cdr
      elsif sym?(key, :quote)
        Literal.build expression.cadr
      elsif sym?(key, "@")
        Assignment.build expression.cdr
      elsif sym?(key, :fn)
        InterpretedFunction.build expression.cadr, expression.cddr
      else
        FunctionInvocation.build expression
      end
    end
  end
end
