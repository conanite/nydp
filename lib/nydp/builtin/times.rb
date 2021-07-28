class Nydp::Builtin::Times
  include Nydp::Builtin::Base, Singleton

  def name ; "*" ; end

  def builtin_call *args
    if args.empty?
      1
    else
      args.reduce(&:*)
    end._nydp_wrapper
  end
end
