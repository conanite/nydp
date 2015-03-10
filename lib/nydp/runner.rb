module Nydp
  class Runner
    attr_accessor :vm, :ns

    def initialize vm, ns
      @vm = vm
      @ns = ns
      @precompile = Symbol.mk(:"pre-compile", ns)
      @quote      = Symbol.mk(:quote, ns)
    end

    def compile_and_eval expr
      vm.thread Pair.new(Compiler.compile(expr, Nydp.NIL), Nydp.NIL)
    end

    def quote expr
      Pair.from_list [@quote, expr]
    end

    def precompile expr
      Pair.from_list [@precompile, quote(expr)]
    end

    def pre_compile expr
      compile_and_eval(precompile(expr))
    end

    def evaluate expr
      compile_and_eval(pre_compile(expr))
    end
  end

  class StreamRunner < Runner
    attr_accessor :stream, :parser

    def initialize vm, ns, stream
      super vm, ns
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
end
