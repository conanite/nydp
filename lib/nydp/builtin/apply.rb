class Nydp::Builtin::Apply
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    args.car.invoke vm, apply_args(args.cdr)
  end

  def builtin_call arg, *args
    original_args = args.dup
    cc            = args.pop
    cc            = [] if cc == nil
    dd            = cc.to_a
    aa            = args.concat(dd)

    arg.call(*aa)._nydp_wrapper
  end

  private

  def apply_args args
    raise "Apply: expected a list : got #{args._nydp_inspect}" unless pair? args
    return args.car if Nydp::NIL.is? args.cdr
    cons args.car, apply_args(args.cdr)
  end
end
