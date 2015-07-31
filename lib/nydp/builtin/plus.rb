class Nydp::Builtin::Plus
  include Nydp::Builtin::Base

  def builtin_invoke vm, args
    vm.push_arg sum(args, origin(args.car))
  end

  def sum args, accum
    if Nydp.NIL.is? args
      accum
    else
      sum(args.cdr, (accum + args.car))
    end
  end

  def origin obj
    case obj
    when Fixnum
      0
    when Nydp::Pair
      Nydp.NIL
    when String, Nydp::StringAtom
      Nydp::StringAtom.new ""
    end
  end

  def name ; "+" ; end
end
