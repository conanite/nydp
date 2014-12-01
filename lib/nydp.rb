module Nydp
  PLUGINS = []

  def self.plug_in plugin;  PLUGINS << plugin                   ; end
  def self.load_rake_tasks; PLUGINS.each &:load_rake_tasks      ; end
  def self.setup ns;        PLUGINS.each { |plg| plg.setup ns } ; end
  def self.loadfiles;       PLUGINS.map(&:loadfiles).flatten    ; end
  def self.testfiles;       PLUGINS.map(&:testfiles).flatten    ; end

  def self.compile_and_eval vm, expr
    vm.thread Pair.new(Compiler.compile(expr, Nydp.NIL), Nydp.NIL)
  end

  class Runner
    attr_accessor :vm, :ns

    def initialize vm, ns
      @vm = vm
      @ns = ns
      @precompile = Symbol.mk(:"pre-compile", ns)
      @quote      = Symbol.mk(:quote, ns)
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

    def evaluate expr
      Nydp.compile_and_eval(vm, pre_compile(expr))
    end
  end

  class StreamRunner < Runner
    attr_accessor :stream, :parser

    def initialize vm, ns, stream
      super vm, ns
      @stream = stream
      @parser = Nydp::Parser.new(ns)
      @tokens = Nydp::Tokeniser.new stream
    end

    def prompt *_
    end

    def run
      res = Nydp.NIL
      prompt
      while !@tokens.finished
        expr = parser.expression(@tokens)
        unless expr.nil?
          res = evaluate expr
          prompt res
        end
      end
      res
    end
  end

  class Repl < StreamRunner
    def prompt val=nil
      puts val if val
      print "nydp > "
    end
  end

  def self.repl
    puts "welcome to nydp"
    root_ns = { }
    setup(root_ns)
    vm = VM.new
    self.loadfiles.each { |f| StreamRunner.new(vm, root_ns, File.new(f)).run }
    Repl.new(vm, root_ns, $stdin).run
  end

  def self.tests
    puts "welcome to nydp : running tests"
    root_ns = { }
    setup(root_ns)
    vm = VM.new
    self.loadfiles.each { |f| StreamRunner.new(vm, root_ns, File.new(f)).run }
    self.testfiles.each { |f| StreamRunner.new(vm, root_ns, File.new(f)).run }
    StreamRunner.new(vm, root_ns, "(run-all-tests)").run
  end
end

require "nydp/core"
require "nydp/error"
require "nydp/truth"
require "nydp/version"
require "nydp/helper"
require "nydp/symbol"
require "nydp/symbol_lookup"
require "nydp/pair"
require "nydp/assignment"
require "nydp/builtin"
require "nydp/string_atom"
require "nydp/string_token"
require "nydp/tokeniser"
require "nydp/parser"
require "nydp/compiler"
require "nydp/vm"
