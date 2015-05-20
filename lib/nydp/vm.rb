module Nydp
  class VM
    include Helper
    attr_accessor :instructions, :args, :contexts, :current_context, :locals, :unhandled_error

    module Finally     ; end
    module HandleError ; end

    def initialize
      @instructions = []
      @args         = []
      @contexts     = []
      @locals       = { }
    end

    def thread expr
      instructions.push expr
      while instructions.length > 0
        begin
          self.current_context = contexts.last
          ii = instructions.pop
          i = ii.car
          ii.cdr.repush instructions, contexts
          i.execute(self)
        rescue Exception => e
          handle_error e
        end
      end
      pop_arg
    end

    def handle_error ex
      @unhandled_error = ex

      protecti = []
      protectc = []

      while (instructions.length > 0) && !(instructions.last.car.is_a? HandleError)
        if instructions.last.car.is_a? Finally
          protecti << instructions.last
          protectc << contexts.last
        end

        instructions.pop
        contexts.pop
      end

      while protecti.length > 0
        push_instructions protecti.pop, proctectc.pop
      end
    end

    def peek_context;  current_context;      end
    def pop_context;   contexts.pop;         end
    def push_arg a;    args.push a;          end
    def peek_arg;      args.last;            end
    def pop_arg;       args.pop;             end

    def push_instructions ii, ctx
      instructions.push ii
      contexts.push ctx
    end

    def pop_args count, tail=Nydp.NIL
      case count
      when 0
        tail
      else
        pop_args(count - 1, cons(pop_arg, tail))
      end
    end

    def vm_info
      msg = ""
      msg << "\n"
      msg << "\ninstruction stack"
      msg << "\n================="
      instructions.each_with_index do |ii, ix|
        msg << "\ninstructions##{ix} : #{ii} #{ii.source if ii.respond_to?(:source)}"
      end
      msg << "\n"
      msg << "\n"
      msg << "\ncontext stack"
      msg << "\n================="
      contexts.each_with_index do |ctx, ix|
        msg << "\ncontext##{ix} :\n#{ctx}"
      end
      msg << "\n"
      msg << "\n"
      msg
    end
  end
end
