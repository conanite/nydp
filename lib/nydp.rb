
module Nydp
  def self.compile_and_eval vm, expr
    vm.thread Pair.new(Compiler.compile(expr), NIL)
  end

  def self.repl
    root_ns = { }
    Symbol.mk(:cons, root_ns).assign(Nydp::Builtin::Cons.new)
    Symbol.mk(:car,  root_ns).assign(Nydp::Builtin::Car.new)
    Symbol.mk(:cdr,  root_ns).assign(Nydp::Builtin::Cdr.new)
    Symbol.mk(:PI,   root_ns).assign Literal.new(3.1415)
    vm = VM.new
    parser = Nydp::Parser.new(root_ns)
    while !$stdin.eof?
      expr = parser.expression(Nydp::Tokeniser.new $stdin.readline)
      puts compile_and_eval(vm, expr).to_s
    end
  end
end

require "nydp/version"
require "nydp/helper"
require "nydp/symbol"
require "nydp/symbol_lookup"
require "nydp/pair"
require "nydp/assignment"
require "nydp/builtin"
require "nydp/nil"
require "nydp/tokeniser"
require "nydp/parser"
require "nydp/compiler"
require "nydp/vm"
require "strscan"
