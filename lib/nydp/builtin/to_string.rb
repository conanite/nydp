class Nydp::Builtin::ToString
  def invoke vm, args
    arg = args.car
    val = case arg.class
          when String, Nydp::StringAtom
            arg
          else
            arg.to_s
          end
    vm.push_arg val
  end
end
