class Nydp::Builtin::Apply
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    args.car.invoke vm, apply_args(args.cdr)
  end

  private

  def apply_args args
    raise "Apply: expected a list : got #{args._nydp_inspect}" unless pair? args
    raise "Apply: improper list : cdr is ruby nil" if args.cdr.nil?
    return args.car if Nydp::NIL.is? args.cdr
    cons args.car, apply_args(args.cdr)
  end
end
