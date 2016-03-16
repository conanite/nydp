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
      @locals       = Nydp::Hash.new
    end

    def thread expr=nil
      instructions.push expr if expr
      while instructions.length > 0
        begin
          thisi = instructions.pop
          if thisi.cdr.is_a? Nydp::Nil
            self.current_context = contexts.pop
          else
            self.current_context = contexts.last
            instructions.push thisi.cdr
          end
          thisi.car.execute(self)
        rescue Exception => e
          handle_error e
        end
      end
      raise_unhandled_error
      pop_arg
    end

    def raise_unhandled_error
      if unhandled_error
        e = unhandled_error
        self.unhandled_error = nil
        raise e
      end
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
        push_instructions protecti.pop, protectc.pop
      end
    end

    def peek_context ; current_context                                           ; end
    def pop_context  ; contexts.pop                                              ; end
    def push_arg a   ; args.push a                                               ; end
    def args!        ; args.empty? ? (raise "illegal operation: no args") : args ; end
    def peek_arg     ; args!.last                                                ; end
    def pop_arg      ; args!.pop                                                 ; end

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
