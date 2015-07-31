class Nydp::Builtin::Quit
  include Nydp::Builtin::Base

  def builtin_invoke vm, args
    exit
  end
end
