class Nydp::Builtin::MathPower
  include Nydp::Builtin::Base, Singleton

  def builtin_call a0, a1 ; a0 ** a1 ; end
end
