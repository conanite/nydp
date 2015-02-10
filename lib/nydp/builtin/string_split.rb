class Nydp::Builtin::StringSplit
  def invoke vm, args
    target    = args.car.to_s
    separator = args.cdr.car.to_s
    result    = target.split separator
    list      = result.map { |s| Nydp::StringAtom.new s }

    vm.push_arg Nydp::Pair.from_list list
  end

  def to_s
    "Builtin:string-split"
  end
end
