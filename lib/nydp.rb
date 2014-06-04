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
    Symbol.mk(:hash, ns).assign(Nydp::Builtin::Hash.new)
    Symbol.mk(:hash, ns).assign(Nydp::Builtin::Hash.new)
    Symbol.mk(:quit, ns).assign(Nydp::Builtin::Quit.new)
    Symbol.mk(:p,    ns).assign(Nydp::Builtin::Puts.new)
    Symbol.mk(:PI,   ns).assign Literal.new(3.1415)
    Symbol.mk(:nil,  ns).assign Nydp.NIL
    Symbol.mk(:comment,       ns).assign(Nydp::Builtin::Comment.new)
    Symbol.mk(:"eq?",         ns).assign(Nydp::Builtin::IsEqual.new)
    Symbol.mk(:"pair?",       ns).assign(Nydp::Builtin::IsPair.new)
    Symbol.mk(:"cdr-set",     ns).assign(Nydp::Builtin::CdrSet.new)
    Symbol.mk(:"hash-get",    ns).assign(Nydp::Builtin::HashGet.new)
    Symbol.mk(:"hash-set",    ns).assign(Nydp::Builtin::HashSet.new)
    Symbol.mk(:"vm-info",     ns).assign Nydp::Builtin::VmInfo.new
    Symbol.mk(:"pre-compile", ns).assign Nydp::Builtin::PreCompile.new
  end

  class Runner
    attr_accessor :vm, :ns, :stream, :parser

    def initialize vm, ns, stream
      @vm = vm
      @ns = ns
      @stream = stream
      @precompile = Symbol.mk(:"pre-compile", ns)
      @quote = Symbol.mk(:quote, ns)
      @parser = Nydp::Parser.new(ns)
      @tokens = Nydp::Tokeniser.new stream
    end

    def quote expr
      Pair.from_list [@quote, expr]
    end

    def precompile expr
      Pair.from_list [@precompile, quote(expr)]
    end

    def pre_compile expr
      prec = Nydp.compile_and_eval(vm, precompile(expr))
      puts "replaced\n#{expr}\nwith#{prec}\n\n"
      prec
    end

    def run
      while !stream.eof?
        Nydp.compile_and_eval(vm, pre_compile(parser.expression(@tokens)))
      end
    end
  end

  class Repl < Runner
    def run
      print "nypd > "
      while !stream.eof?
        expr = parser.expression(@tokens)
        puts Nydp.compile_and_eval(vm, pre_compile(expr)).to_s
        print "nypd > "
      end
    end
  end

  def self.repl
    root_ns = { }
    setup(root_ns)
    vm = VM.new
    boot_path = File.join File.expand_path(File.dirname(__FILE__)), 'lisp/boot.nydp'
    puts "boot path #{boot_path}"
    boot = File.new boot_path
    puts boot
    Runner.new(vm, root_ns, boot).run
    Repl.new(vm, root_ns, $stdin).run
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
