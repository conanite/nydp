class Nydp::Builtin::Apply
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  def builtin_call arg, *args
    original_args = args.dup
    cc            = args.pop
    cc            = [] if cc == nil
    dd            = cc.to_a
    aa            = args.concat(dd)

    arg.call(*aa)._nydp_wrapper
  end

end
