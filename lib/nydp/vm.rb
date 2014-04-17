module Nydp
  class VM
    include Helper
    attr_accessor :instructions, :args

    def initialize
      @instructions = []
      @args = []
    end

    def thread expr
      puts expr
      instructions.push expr
      while instructions.length > 0
        if NIL.is?(instructions.last)
          instructions.pop
        else
          ii = instructions.pop
          i = ii.car
          instructions.push ii.cdr
          i.execute(self)
        end
      end
      pop_arg
    end

    def push_instructions ii
      instructions.push ii
    end

    def push_arg a
      args.push a
    end

    def pop_arg
      args.pop
    end

    def pop_args count, tail=NIL
      case count
      when 0
        tail
      else
        pop_args(count - 1, cons(pop_arg, tail))
      end
    end
  end
end
