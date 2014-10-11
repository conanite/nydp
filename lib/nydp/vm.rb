module Nydp
  class VM
    include Helper
    attr_accessor :instructions, :args, :contexts, :current_context

    def initialize
      @instructions = []
      @args = []
      @contexts = []
    end

    def thread expr
      instructions.push expr
      while instructions.length > 0
        # puts "instruction stack"
        # puts "================="
        # instructions.each_with_index do |ii, ix|
        #   puts "instructions##{ix} : #{ii}"
        # end
        # puts
        # puts
        # puts "context stack"
        # puts "================="
        # contexts.each_with_index do |ctx, ix|
        #   puts "context##{ix} : #{ctx}"
        # end
        # puts
        # puts
        self.current_context = contexts.last
        ii = instructions.pop
        i = ii.car
        ii.cdr.repush instructions, contexts
        i.execute(self)
      end
      pop_arg
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

    def error e
      puts "     error"
      puts e
      puts "================="
      puts
      puts "instruction stack"
      puts "================="
      instructions.each_with_index do |ii, ix|
        puts "instructions##{ix} : #{ii} #{ii.source if ii.respond_to?(:source)}"
      end
      puts
      puts
      puts "context stack"
      puts "================="
      contexts.each_with_index do |ctx, ix|
        puts "context##{ix} : #{ctx}"
      end
      puts
      puts

      instructions = []
      contexts     = []
      args = [Nydp.NIL]
    end
  end
end
