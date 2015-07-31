class Nydp::Builtin::CdrSet
  include Nydp::Builtin::Base

  def builtin_invoke vm, args
    pair = args.car
    arg = args.cdr.car
    pair.cdr = arg
    vm.push_arg pair
  end
end
