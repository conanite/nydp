module Nydp
  class Closure
    attr_accessor :ifn, :context

    def initialize ifn, context
      @ifn, @context = ifn, context
    end

    def invoke vm, arg_values
      ifn.invoke vm, context, arg_values
    end

    def to_s
      "(closure #{context.inspect} : #{ifn.to_s})"
    end
  end
end
