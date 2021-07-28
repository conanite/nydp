class Nydp::Builtin::SetIntersection
  include Nydp::Builtin::Base, Singleton

  def builtin_call *args
    args.reduce(&:&)._nydp_wrapper
  end
end
