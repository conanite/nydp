class Nydp::Builtin::Plus
  include Nydp::Builtin::Base

  def builtin_invoke vm, args
    vm.push_arg case args.car
                when Fixnum, Nydp::Date
                  sum(args.cdr, args.car)
                when Nydp::Pair
                  sum(args, Nydp.NIL)
                when String, Nydp::StringAtom
                  sum(args, Nydp::StringAtom.new(""))
                end
  end

  def sum args, accum
    if Nydp.NIL.is? args
      accum
    else
      sum(args.cdr, (accum + args.car))
    end
  end

  def name ; "+" ; end
end
