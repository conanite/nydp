class Nydp::Builtin::MathRound
  include Nydp::Builtin::Base, Singleton

  def builtin_call arg
    arg.round
  end
end
