class Nydp::Builtin::MathCeiling
  include Nydp::Builtin::Base, Singleton

  def builtin_call arg ; arg.ceil ; end
end
