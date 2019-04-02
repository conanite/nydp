class Nydp::Builtin::Date
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    case args.size
    when 0 ; builtin_invoke_1 vm
    when 1 ; builtin_invoke_2 vm, args.car
    when 2 ; builtin_invoke_3 vm, args.car, args.cdr.car
    when 3 ; builtin_invoke_4 vm, args.car, args.cdr.car, args.cdr.cdr.car
    end
  end

  def builtin_invoke_1 vm
    vm.push_arg(Nydp::Date.new Date.today)
  end

  # it's a Time object (or any object that responds to #to_date)
  def builtin_invoke_2 vm, arg
    vm.push_arg(Nydp::Date.new arg.to_date)
  end

  def builtin_invoke_3 vm, a0, a1
    raise Nydp::Error.new "Date, got 2 args (#{a0} #{a1}), expected 0 or 1 or 3 args"
  end

  def builtin_invoke_4 vm, y, m, d
    vm.push_arg(Nydp::Date.new Date.new(y,m,d))
  end
end
