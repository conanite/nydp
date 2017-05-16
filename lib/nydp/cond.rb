module Nydp
  class ExecuteConditionalInstruction
    extend Helper

    def initialize when_true, when_false
      @when_true, @when_false = when_true, when_false
    end

    def execute vm
      (Nydp::NIL.is?(vm.args.pop) ? @when_false : @when_true).execute vm
    end

    def inspect
      "when_true:#{@when_true.inspect}:when_false:#{@when_false.inspect}"
    end
    def to_s
      "#{@when_true.to_s} #{@when_false.to_s}"
    end
  end

  class Cond
    extend Helper
    include Helper
    attr_reader :condition, :conditional

    def initialize cond, when_true, when_false
      @condition, @conditional = cond, cons(ExecuteConditionalInstruction.new(when_true, when_false))
    end

    def execute vm
      vm.instructions.push conditional
      vm.contexts.push vm.current_context
      condition.execute vm
    end

    def inspect
      "cond:#{condition.inspect}:#{conditional.inspect}"
    end
    def to_s
      "(cond #{condition.to_s} #{conditional.to_s})"
    end

    def self.build expressions, bindings
      if expressions.is_a? Nydp::Pair
        cond       = Compiler.compile expressions.car, bindings
        when_true  = Compiler.compile expressions.cdr.car, bindings
        when_false = Compiler.compile expressions.cdr.cdr.car, bindings
        csig       = sig(cond)
        # puts cond_sig
        # TODO : handle literal nil explicitly (if x y) -> #when_false is literal nil, we can hardcode that
        # todo : handle "OR" explicitly -> (if x x y) -> when #cond equals #when_true, hardcode this case
        case csig
        when "LEX"
          Cond_LEX.build(cond, when_true, when_false)
        when "SYM"
          Cond_SYM.new(cond, cons(when_true), cons(when_false))
        else
          new(cond, when_true, when_false)
        end
      else
        raise "can't compile Cond: #{expr.inspect}"
      end
    end
  end

  class CondBase
    extend Helper
    include Helper

    def initialize cond, when_true, when_false
      @condition, @when_true, @when_false = cond, when_true, when_false
    end

    def inspect ; "cond:#{@condition.inspect}:#{@when_true.inspect}:#{@when_false.inspect}" ; end
    def to_s    ; "(cond #{@condition.to_s} #{@when_true.to_s} #{@when_false.to_s})" ; end
  end

  class Cond_LEX < CondBase
    def execute vm
      truth = !Nydp::NIL.is?(@condition.value vm.current_context)
      vm.instructions.push (truth ? @when_true : @when_false)
      vm.contexts.push vm.current_context
    end

    def self.build cond, when_true, when_false
      tsig       = sig(when_true)
      fsig       = sig(when_false)
      cond_sig = "#{tsig}_#{fsig}"

      # if (cond == when_true)
      #   OR_LEX.build cond, when_false

      if (cond == when_true) && (fsig == "LIT")
        OR_LEX_LIT.new cond, nil, when_false
      elsif (cond == when_true) && (fsig == "LEX")
        OR_LEX_LEX.new cond, nil, when_false
      else
        case cond_sig
        when "LIT_LIT"
          Nydp::Cond_LEX_LIT_LIT.new(cond, when_true.expression, when_false.expression)
        when "LEX_LIT"
          Nydp::Cond_LEX_LEX_LIT.new(cond, when_true, when_false.expression)
        when "CND_LIT"
          Nydp::Cond_LEX_CND_LIT.new(cond, when_true, when_false.expression)
        else
          Nydp::Cond_LEX.new(cond, cons(when_true), cons(when_false))
        end
      end
    end
  end

  class OR_LEX_LIT < CondBase
    def execute vm
      value = @condition.value vm.current_context
      vm.push_arg(!Nydp::NIL.is?(value) ? value : @when_false)
    end
  end

  class OR_LEX_LEX < CondBase
    def execute vm
      value = @condition.value vm.current_context
      vm.push_arg(!Nydp::NIL.is?(value) ? value : (@when_false.value vm.current_context))
    end
  end

  # class OR_LEX < CondBase
  #   def execute vm
  #     value = @condition.value vm.current_context
  #     if !Nydp::NIL.is?(value)
  #       vm.push_arg value
  #     else
  #       @when_false.execute vm
  #     end
  #   end

  #   def self.build cond, when_false
  #     case sig(when_false)
  #     when "LIT"
  #       OR_LEX_LIT.new(cond, nil, when_false)
  #     when "LEX"
  #       OR_LEX_LEX.new(cond, nil, when_false)
  #     else
  #       OR_LEX.new(cond, nil, when_false)
  #     end
  #   end
  # end

  class Cond_LEX_LIT_LIT < CondBase # (def no (arg) (cond arg nil t))
    def execute vm
      falsity = Nydp::NIL.is?(@condition.value vm.current_context)
      vm.push_arg(falsity ? @when_false : @when_true)
    end
  end

  class Cond_LEX_LEX_LIT < CondBase
    def execute vm
      falsity = Nydp::NIL.is?(@condition.value vm.current_context)
      vm.push_arg(falsity ? @when_false : (@when_true.value vm.current_context))
    end
  end

  class Cond_LEX_CND_LIT < CondBase
    def execute vm
      if Nydp::NIL.is?(@condition.value vm.current_context)
        vm.push_arg @when_false
      else
        @when_true.execute vm
      end
    end
  end

  class Cond_SYM < CondBase
    def execute vm
      vm.instructions.push (Nydp::NIL.is?(@condition.value) ? @when_false : @when_true)
      vm.contexts.push vm.current_context
    end
  end
end
