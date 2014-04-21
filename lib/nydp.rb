module Nydp
  def self.compile_and_eval vm, expr
    vm.thread Pair.new(Compiler.compile(expr, Nydp.NIL), Nydp.NIL)
  end

  def self.setup ns
    Symbol.mk(:cons, ns).assign(Nydp::Builtin::Cons.new)
    Symbol.mk(:car,  ns).assign(Nydp::Builtin::Car.new)
    Symbol.mk(:cdr,  ns).assign(Nydp::Builtin::Cdr.new)
    Symbol.mk(:+,    ns).assign(Nydp::Builtin::Plus.new)
    Symbol.mk(:*,    ns).assign(Nydp::Builtin::Times.new)
    Symbol.mk(:PI,   ns).assign Literal.new(3.1415)
    Symbol.mk(:nil,  ns).assign Nydp.NIL
  end

  def self.repl
    root_ns = { }
    setup(root_ns)
    vm = VM.new
    parser = Nydp::Parser.new(root_ns)
    while !$stdin.eof?
      expr = parser.expression(Nydp::Tokeniser.new $stdin.readline)
      puts compile_and_eval(vm, expr).to_s
    end
  end
end

require "nydp/nil"
require "nydp/version"
require "nydp/helper"
require "nydp/symbol"
require "nydp/symbol_lookup"
require "nydp/pair"
require "nydp/assignment"
require "nydp/builtin"
require "nydp/tokeniser"
require "nydp/parser"
require "nydp/compiler"
require "nydp/vm"
