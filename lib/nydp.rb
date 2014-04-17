
module Nydp
  RootNS = { }

  class Interpreter
    def interpret expression
      expression.interpret
    end
  end

  def self.root_ns
    RootNS
  end

  def self.compile_and_eval vm, expr
    vm.thread Pair.new(Compiler.compile(expr), NIL)
  end

  def self.repl
    Symbol.mk(:PI, RootNS).assign Literal.new(3.1415)
    vm = VM.new
    parser = Nydp::Parser.new(RootNS)
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
require "nydp/builtin"
require "nydp/nil"
require "nydp/tokeniser"
require "nydp/parser"
require "nydp/compiler"
require "nydp/vm"
require "strscan"
