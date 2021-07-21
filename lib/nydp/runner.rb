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
      @name = name
      @vm   = vm
      @ns   = ns
    end

    def compile_expr expr
      begin
        Compiler.compile(expr, Nydp::NIL, ns)
      rescue StandardError => e
        raise Nydp::Error, "failed to compile #{expr._nydp_inspect}"
      end
    end

    def eval_compiled compiled_expr, src
      begin
        ruby_expr = compiled_expr.compile_to_ruby
        proc_expr = "->(ns) { #{ruby_expr} }"
        eval(proc_expr, nil, src._nydp_inspect).call(ns)
      rescue Exception => e
        raise Nydp::Error, "failed to eval #{compiled_expr._nydp_inspect} from src #{src._nydp_inspect}"
      end
    end

    def pre_compile expr
      precompile = Pair.from_list [:"pre-compile", Pair.from_list([:quote, expr])]
      compiled   = compile_expr precompile
      eval_compiled compiled, precompile
    end

    def evaluate expr
      precompiled = pre_compile(expr)
      compiled    = compile_expr precompiled
      eval_compiled compiled, expr
    end
  end

  class Runner < Evaluator
    def initialize vm, ns, stream, printer=nil, name=nil
      super vm, ns, name
      @printer    = printer
      @parser     = Nydp.new_parser
      @tokens     = Nydp.new_tokeniser stream
    end

    def print val
      @printer.puts val._nydp_inspect if @printer
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
