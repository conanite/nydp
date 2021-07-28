class Nydp::Builtin::Divide
  include Nydp::Builtin::Base, Singleton

  def name ; "/" ; end

  def builtin_call *args
    (args.reduce &:/)._nydp_wrapper
  end

end
