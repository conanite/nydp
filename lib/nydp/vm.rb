module Nydp
  class VM
    include Helper
    attr_accessor :instructions, :args, :contexts

    def initialize
      @instructions = []
      @args = []
      @contexts = []
    end

    def thread expr
      instructions.push expr
      while instructions.length > 0
        if Nydp.NIL.is?(instructions.last)
          instructions.pop
        else
          ii = instructions.pop
          i = ii.car
          instructions.push ii.cdr
          # puts "executing #{i}"
          i.execute(self)
        end
      end
      pop_arg
    end

    def push_context lc;      contexts.push lc;     end
    def peek_context;         contexts.last;        end
    def pop_context;          contexts.pop;         end
    def push_arg a;           args.push a;          end
    def peek_arg;             args.last;            end
    def pop_arg;              args.pop;             end
    def push_instructions ii; instructions.push ii; end

    def pop_args count, tail=Nydp.NIL
      case count
      when 0
        tail
      else
        pop_args(count - 1, cons(pop_arg, tail))
      end
    end
  end
end
