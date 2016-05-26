class Nydp::Builtin::StringSplit
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    target    = args.car.to_s
    separator = args.cdr.car.to_s
    result    = target.split separator, -1
    list      = result.map { |s| Nydp::StringAtom.new s }

    vm.push_arg Nydp::Pair.from_list list
  end
end
