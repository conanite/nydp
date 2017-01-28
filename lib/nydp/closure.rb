module Nydp
  class Closure
    attr_accessor :ifn, :context

    def initialize ifn, context
      @ifn, @context = ifn, context
    end

    def invoke_1 vm
      ifn.invoke_1 vm, context
    end

    def invoke_2 vm, arg
      ifn.invoke_2 vm, context, arg
    end

    def invoke_3 vm, arg_0, arg_1
      ifn.invoke_3 vm, context, arg_0, arg_1
    end

    def invoke_4 vm, arg_0, arg_1, arg_2
      ifn.invoke_4 vm, context, arg_0, arg_1, arg_2
    end

    def invoke vm, arg_values
      ifn.invoke vm, context, arg_values
    end

    def nydp_type ; "fn" ; end
    def to_s
      "(closure #{context.to_s} : #{ifn.to_s})"
    end
    def inspect ; to_s ; end
  end
end
