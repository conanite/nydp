module Nydp
  class VM
    NIL = Nydp::NIL
    include Helper
    attr_accessor :instructions, :args, :contexts, :current_context, :locals, :unhandled_error, :last_error, :ns, :thisi

    module Finally     ; end
    module HandleError ; end

    def initialize ns
      @instructions = []
      @args         = []
      @contexts     = []
      @locals       = Nydp::Hash.new
      @ns           = ns
    end

    def push_instructions ii, ctx
      if @current_instructions && NIL != @current_instructions
        @instructions.push @current_instructions
        @contexts.push @current_context
      end

      @current_instructions = ii
      @current_context = ctx
    end

    def push_ctx_instructions ii
      if @current_instructions && NIL != @current_instructions
        @instructions.push @current_instructions
        @contexts.push @current_context
      end

      @current_instructions = ii
    end

    def thread_with_expr expr
      @current_instructions = expr
      thread
    end

    def thread
      while @current_instructions
        begin
          if NIL == @current_instructions
            @current_instructions = @instructions.pop
            @current_context      = @contexts.pop
          else
            now = @current_instructions.car
            @current_instructions = @current_instructions.cdr
            now.execute(self)
          end

        rescue StandardError => e
          handle_error e
        end
      end

      if @unhandled_error
        e = @unhandled_error
        @unhandled_error = nil
        raise e
      end

      args.pop
    end

    def handle_error ex
      @unhandled_error = ex

      protecti = []
      protectc = []

      while (@instructions.length > 0) && !(@instructions.last.car.is_a? HandleError)
        if @instructions.last.car.is_a? Finally
          protecti << @instructions.last
          protectc << @contexts.last
        end

        @instructions.pop
        @contexts.pop
      end

      while protecti.length > 0
        push_instructions protecti.pop, protectc.pop
      end
    end

    def push_arg a   ; args.push a                                               ; end
    def args!        ; args.empty? ? (raise "illegal operation: no args") : args ; end
    def peek_arg     ; args!.last                                                ; end

    def pop_args count, tail=Nydp::NIL
      case count
      when 0
        tail
      else
        pop_args(count - 1, cons(args.pop, tail))
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
      msg << "\nargs stack"
      msg << "\n================="
      args.each_with_index do |args, ix|
        msg << "\args##{ix} :\n#{args}"
      end
      msg << "\n"
      msg << "\n"
      msg
    end
  end
end
