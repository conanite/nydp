class Nydp::Builtin::ToString
  def invoke vm, args
    arg = args.car
    val = case arg.class
          when Nydp::StringAtom
            arg
          else
            Nydp::StringAtom.new arg.to_s
          end
    vm.push_arg val
  end
end

class Nydp::Builtin::StringPieces
  def to_string first, rest
    if Nydp.NIL.is? rest
      first.to_s
    else
      "#{first.to_s}#{to_string rest.car, rest.cdr}"
    end
  end

  def invoke vm, args
    vm.push_arg to_string(args.car, args.cdr)
  end
end
