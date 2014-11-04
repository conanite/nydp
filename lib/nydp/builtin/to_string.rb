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
