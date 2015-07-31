class Nydp::Builtin::StringReplace
  include Nydp::Builtin::Base

  def builtin_invoke vm, args
    to_remove = args.car.to_s
    to_insert = args.cdr.car.to_s
    target    = args.cdr.cdr.car.to_s
    result    = target.to_s.gsub to_remove, to_insert

    vm.push_arg Nydp::StringAtom.new result
  end
end
