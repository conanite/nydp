module Nydp::Builtin
  class ToString
    include Nydp::Builtin::Base, Singleton

    def builtin_call arg=nil ; arg.to_s ; end
  end

  class StringLength
    include Nydp::Builtin::Base, Singleton

    def builtin_call arg ; arg.to_s.length ; end
  end
end
