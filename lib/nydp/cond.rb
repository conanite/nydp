module Nydp
  class Cond
    extend Helper
    include Helper
    attr_reader :condition, :conditional

    def initialize cond, when_true, when_false
      @condition, @when_true, @when_false = cond, when_true, when_false
    end

    def lexical_reach n
      [@condition.lexical_reach(n), @when_true.lexical_reach(n), @when_false.lexical_reach(n)].max
    end

    def execute vm
      if (@condition.execute(vm))
        @when_true.execute(vm)
      else
        @when_false.execute(vm)
      end
    end

    def compile_to_ruby indent, srcs, opts=nil
      if (!@when_false) || (@when_false.is_a?(Nydp::Literal) && !@when_false.expression)
        "#{indent}if (#{@condition.compile_to_ruby "", srcs})
#{@when_true.compile_to_ruby(indent + "  ", srcs, cando: true)}
#{indent}end"
      else
        "#{indent}if (#{@condition.compile_to_ruby "", srcs})
#{@when_true.compile_to_ruby(indent + "  ", srcs, cando: true)}
#{indent}else
#{@when_false.compile_to_ruby(indent + "  ", srcs, cando: true)}
#{indent}end"
      end
    end

    def inspect
      "(cond #{condition._nydp_inspect} #{@when_true._nydp_inspect} #{@when_false._nydp_inspect})"
    end

    def to_s
      "(cond #{condition.to_s} #{@when_true.to_s} #{@when_false.to_s})"
    end

    def self.build expressions, bindings, ns
      if expressions.is_a? Nydp::Pair
        cond       = Compiler.compile expressions.car, bindings, ns
        when_true  = Compiler.compile expressions.cdr.car, bindings, ns
        when_false = Compiler.compile expressions.cdr.cdr.car, bindings, ns
        csig       = sig(cond)
        xsig       = "#{sig(cond)}_#{sig(when_true)}_#{sig(when_false)}"

        # case csig
        # when "LEX"
        #   Cond_LEX.build(cond, when_true, when_false)
        # when "SYM"
        #   Cond_SYM.new(cond, when_true, when_false)
        # else
        #   new(cond, when_true, when_false)
        # end

        new(cond, when_true, when_false)
      else
        raise "can't compile Cond: #{expressions._nydp_inspect}"
      end
    end
  end

  class CondBase
    extend Helper
    include Helper

    def initialize cond, when_true, when_false
      @condition, @when_true, @when_false = cond, when_true, when_false
    end

    def lexical_reach n
      [@condition.lexical_reach(n), @when_true.lexical_reach(n), @when_false.lexical_reach(n)].max
    end

    def inspect ; "cond:#{@condition._nydp_inspect}:#{@when_true._nydp_inspect}:#{@when_false._nydp_inspect}" ; end
    def to_s    ; "(cond #{@condition.to_s} #{@when_true.to_s} #{@when_false.to_s})" ; end
    # def compile_to_ruby indent
    #   "((#{@condition.compile_to_ruby "", srcs}) ? (#{@when_true.compile_to_ruby "", srcs}) : (#{@when_false.compile_to_ruby "", srcs}))"
    # end
  end

  class Cond_LEX < CondBase
    def execute vm
      if @condition.value vm.current_context
        @when_true.execute(vm)
      else
        @when_false.execute(vm)
      end
    end

    def lexical_reach n
      cr = @condition.lexical_reach(n)
      ct = @when_true.lexical_reach(n)
      cf = @when_false.lexical_reach(n)

      [cr, ct, cf].max
    end

    def self.build cond, when_true, when_false
      tsig       = sig(when_true)
      fsig       = sig(when_false)
      cond_sig = "#{tsig}_#{fsig}"

      if (cond == when_true) && (fsig == "LIT")
        OR_LEX_LIT.new cond, nil, when_false.expression
      elsif (cond == when_true) && (fsig == "LEX")
        OR_LEX_LEX.new cond, nil, when_false
      elsif (cond == when_true)
        OR_LEX_XXX.new cond, nil, when_false
      else
        case cond_sig
        when "LIT_LIT"
          # puts "building Cond_LEX_LIT_LIT #{[cond, when_true.expression, when_false.expression]}"
          Nydp::Cond_LEX_LIT_LIT.new(cond, when_true.expression, when_false.expression)
        when "LEX_LIT"
          Nydp::Cond_LEX_LEX_LIT.new(cond, when_true, when_false.expression)
        when "CND_LIT"
          Nydp::Cond_LEX_CND_LIT.new(cond, when_true, when_false.expression)
        when "NVB_LEX"
          Nydp::Cond_LEX_NVB_LEX.new(cond, when_true, when_false)
        when "NVB_LIT"
          Nydp::Cond_LEX_NVB_LIT.new(cond, when_true, when_false.expression)
        else
          new(cond, when_true, when_false)
        end
      end
    end
  end

  class OR_LEX_LIT < CondBase
    def execute vm
      @condition.value(vm.current_context) || @when_false
    end
  end

  class OR_LEX_LEX < CondBase
    def execute vm
      @condition.value(vm.current_context) || (@when_false.value vm.current_context)
    end
  end

  class OR_LEX_XXX < CondBase
    def execute vm
      @condition.value(vm.current_context) || (@when_false.execute vm)
    end
  end

  class Cond_LEX_LIT_LIT < CondBase # (def no (arg) (cond arg nil t))
    def execute vm
      (@condition.value vm.current_context) ? @when_true : @when_false
    end
  end

  class Cond_LEX_LEX_LIT < CondBase
    def execute vm
      (@condition.value vm.current_context) ? (@when_true.value vm.current_context) : @when_false
    end
  end

  class Cond_LEX_CND_LIT < CondBase
    def execute vm
      if (@condition.value vm.current_context)
        @when_true.execute vm
      else
        @when_false
      end
    end
  end

  class Cond_LEX_NVB_LEX < CondBase
    def execute vm
      if (@condition.value vm.current_context)
        @when_true.execute vm
      else
        @when_false.value(vm.current_context)
      end
    end
  end

  class Cond_LEX_NVB_LIT < CondBase
    def execute vm
      if (@condition.value vm.current_context)
        @when_true.execute vm
      else
        @when_false
      end
    end
  end

  class Cond_SYM < CondBase
    def execute vm
      # puts "Cond_SYM"
      (@condition.value) ? @when_true.execute(vm) : @when_false.execute(vm)
    end
  end
end
