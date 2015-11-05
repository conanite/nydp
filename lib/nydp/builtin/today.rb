class Nydp::Builtin::Today
  include Nydp::Helper, Nydp::Builtin::Base

  def builtin_invoke vm, args
    vm.push_arg(Nydp::Date.new Date.today)
  end
end

class Nydp::Builtin::Date
  include Nydp::Helper, Nydp::Builtin::Base

  def builtin_invoke vm, args
    y = args.car
    m = args.cdr.car
    d = args.cdr.cdr.car
    vm.push_arg(Nydp::Date.new Date.new(y,m,d))
  end
end
