module Nydp
  class StringReader
    def initialize string ; @string = string ; end
    def nextline
      s = @string ; @string = "" ; s
    end
  end

  class StreamReader
    def initialize stream ; @stream = stream ; end
    def nextline
      (@stream && !@stream.eof?) ? @stream.readline : ""
    end
  end

  class RawlineReader
    def initialize stream, prompt
      @prompt = prompt
      @editor = Rawline::Editor.new stream
    end

    def nextline ; @editor.read @prompt ; end
  end

  class Evaluator
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

  class Runner < Evaluator
    def initialize vm, ns, stream
      super vm, ns
      @parser     = Nydp::Parser.new(ns)
      @tokens     = Nydp::Tokeniser.new stream
    end

    def run
      res = Nydp.NIL
      while !@tokens.finished
        expr = @parser.expression(@tokens)
        unless expr.nil?
          res = evaluate expr
        end
      end
      res
    end
  end
end
