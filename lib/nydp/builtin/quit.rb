class Nydp::Builtin::Quit
  include Nydp::Builtin::Base

  def builtin_call *args
    exit
  end
end
