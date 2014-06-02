class Nydp::Builtin::VmInfo
  def invoke vm, args
    context_count = Nydp::Pair.new "contexts", vm.contexts.size
    instruction_count = Nydp::Pair.new "instruction lists", vm.instructions.size
    arg_count = Nydp::Pair.new "args", vm.args.size
    vm.push_arg Nydp::Pair.from_list [context_count, instruction_count, arg_count]
  end
end
