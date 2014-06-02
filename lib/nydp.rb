module Nydp
  def self.compile_and_eval vm, expr
    vm.thread Pair.new(Compiler.compile(expr, Nydp.NIL), Nydp.NIL)
  end

  def self.setup ns
    Symbol.mk(:cons, ns).assign(Nydp::Builtin::Cons.new)
    Symbol.mk(:car,  ns).assign(Nydp::Builtin::Car.new)
    Symbol.mk(:cdr,  ns).assign(Nydp::Builtin::Cdr.new)
    Symbol.mk(:+,    ns).assign(Nydp::Builtin::Plus.new)
    Symbol.mk(:-,    ns).assign(Nydp::Builtin::Minus.new)
    Symbol.mk(:*,    ns).assign(Nydp::Builtin::Times.new)
    Symbol.mk(:>,    ns).assign(Nydp::Builtin::GreaterThan.new)
    Symbol.mk(:<,    ns).assign(Nydp::Builtin::LessThan.new)
    Symbol.mk(:quit, ns).assign(Nydp::Builtin::Quit.new)
    Symbol.mk(:PI,   ns).assign Literal.new(3.1415)
    Symbol.mk(:nil,  ns).assign Nydp.NIL
    Symbol.mk(:"vm-info", ns).assign Nydp::Builtin::VmInfo.new
    Symbol.mk(:"pre-compile", ns).assign Nydp::Builtin::PreCompile.new
  end

  class Repl
    attr_accessor :vm, :ns, :stream, :parser

    def initialize vm, ns, stream
      @vm = vm
      @ns = ns
      @stream = stream
      @precompile = Symbol.mk(:"pre-compile", ns)
      @quote = Symbol.mk(:quote, ns)
      @parser = Nydp::Parser.new(ns)
    end

    def repl
      print "nypd > "
      while !stream.eof?
        expr = parser.expression(Nydp::Tokeniser.new stream.readline)
        puts Nydp.compile_and_eval(vm, pre_compile(expr)).to_s
        print "nypd > "
      end
    end

    def quote expr
      Pair.from_list [@quote, expr]
    end

    def precompile expr
      Pair.from_list [@precompile, quote(expr)]
    end

    def pre_compile expr
      Nydp.compile_and_eval(vm, precompile(expr))
    end
  end

  def self.repl
    root_ns = { }
    setup(root_ns)
    vm = VM.new
    Repl.new(vm, root_ns, $stdin).repl
  end
end

require "nydp/truth"
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
