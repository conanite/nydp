module Nydp::Builtin
  class ToString
    include Nydp::Builtin::Base, Singleton

    def builtin_call arg=nil ; arg._nydp_to_s ; end
  end

  class StringLength
    include Nydp::Builtin::Base, Singleton

    def builtin_call arg ; arg._nydp_to_s.length ; end
  end
end
