module Nydp
  class Builtin::Sort
    include Builtin::Base, Singleton

    def builtin_call arg
      arg.to_a.sort._nydp_wrapper
    end

  end
end
