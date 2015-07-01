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

class Nydp::Builtin::StringLength
  def invoke vm, args
    arg = args.car
    val = case arg
          when Nydp::StringAtom
            arg.length
          else
            0
          end
    vm.push_arg val
  end
end
