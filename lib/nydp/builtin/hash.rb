class Nydp::Builtin::Hash
  def invoke vm, args
    vm.push_arg({ })
  end
end

class Nydp::Builtin::HashGet
  def invoke vm, args
    hash = args.car
    key = args.cdr.car
    vm.push_arg(hash[key] || Nydp.NIL)
  end
end

class Nydp::Builtin::HashSet
  def invoke vm, args
    hash = args.car
    key = args.cdr.car
    value = args.cdr.cdr.car
    hash[key] = value
    vm.push_arg value
  end
end
