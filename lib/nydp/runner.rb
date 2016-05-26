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
    attr_accessor :vm, :ns

    def initialize vm, ns
      @vm = vm
      @ns = ns
      @precompile = Symbol.mk(:"pre-compile", ns)
      @quote      = Symbol.mk(:quote, ns)
    end

    def compile_and_eval expr
      begin
        vm.thread Pair.new(Compiler.compile(expr, Nydp::NIL), Nydp::NIL)
      rescue Exception => e
        new_msg = "failed to eval #{expr.inspect}\nerror was #{Nydp.indent_text e.message}"
        raise e.class, new_msg, e.backtrace
      end
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
    def initialize vm, ns, stream, printer=nil
      super vm, ns
      @printer    = printer
      @parser     = Nydp::Parser.new(ns)
      @tokens     = Nydp::Tokeniser.new stream
    end

    def print val
      @printer.puts val.inspect if @printer
    end

    def handle_run_error e
      puts e.message
      e.backtrace.each do |b|
        puts b
      end
    end

    def run
      res = Nydp::NIL
      while !@tokens.finished
        expr = @parser.expression(@tokens)
        unless expr.nil?
          begin
            print(res = evaluate(expr))
          rescue Exception => e
            handle_run_error e
          end
        end
      end
      res
    end
  end

  class ExplodeRunner < Runner
    def handle_run_error e
      raise e
    end
  end
end
