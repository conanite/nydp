class Nydp::Builtin::MathFloor
  include Nydp::Builtin::Base, Singleton

  def builtin_call arg ; arg.floor ; end
end
