class Nydp::Builtin::Abs
  include Nydp::Builtin::Base, Singleton

  def name ; "mod" ; end

  def builtin_call arg
    arg.abs
  end
end
