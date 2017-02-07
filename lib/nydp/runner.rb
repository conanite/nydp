require 'readline'
require 'nydp/readline_history'

module Nydp
  class StringReader
    def initialize string ; @string = string ; end
    def nextline
      s = @string ; @string = nil ; s
    end
  end

  class StreamReader
    def initialize stream ; @stream = stream ; end
    def nextline
      @stream.readline unless @stream.eof?
    end
  end

  class ReadlineReader
    include Nydp::ReadlineHistory

    def initialize stream, prompt
      @prompt = prompt
      setup_readline_history
    end

    # with thanks to http://ruby-doc.org/stdlib-1.9.3/libdoc/readline/rdoc/Readline.html
    # and http://bogojoker.com/readline/
    def nextline
      line = Readline.readline(@prompt, true)
      return nil if line.nil?
      if line =~ /^\s*$/ or Readline::HISTORY.to_a[-2] == line
        Readline::HISTORY.pop
      end
      line
    end
  end

  class Evaluator
    attr_accessor :vm, :ns, :name

    def initialize vm, ns, name
      @name       = name
      @vm         = vm
      @ns         = ns
      @precompile = Symbol.mk(:"pre-compile", ns)
      @quote      = Symbol.mk(:quote, ns)
    end

    def compile_and_eval expr
      begin
        vm.thread Pair.new(Compiler.compile(expr, Nydp::NIL), Nydp::NIL)
      rescue StandardError => e
        raise Nydp::Error, "failed to eval #{expr.inspect}"
      end
    end

    def pre_compile expr
      compile_and_eval(Pair.from_list [@precompile, Pair.from_list([@quote, expr])])
    end

    def evaluate expr
      compile_and_eval(pre_compile(expr))
    end
  end

  class Runner < Evaluator
    def initialize vm, ns, stream, printer=nil, name=nil
      super vm, ns, name
      @printer    = printer
      @parser     = Nydp::Parser.new(ns)
      @tokens     = Nydp::Tokeniser.new stream
    end

    def print val
      @printer.puts val.inspect if @printer
    end

    def run
      Nydp.apply_function ns, :"script-run", :"script-start", name
      res = Nydp::NIL
      begin
        while !@tokens.finished
          expr = @parser.expression(@tokens)
          print(res = evaluate(expr)) unless expr.nil?
        end
      ensure
        Nydp.apply_function ns, :"script-run", :"script-end", name
      end
      res
    end
  end
end
