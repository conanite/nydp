module Nydp::Builtin
  class ToInteger
    include Nydp::Builtin::Base, Singleton

    def builtin_call arg
      arg = n2r arg

      if arg.respond_to? :to_i
        arg.to_i
      elsif arg.respond_to? :to_time
        arg.to_time.to_i
      else
        arg.to_s.to_i
      end
    end
  end
end
