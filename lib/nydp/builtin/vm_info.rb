class Nydp::Builtin::VmInfo
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    context_count     = Nydp::Pair.new :contexts,     vm.contexts.size
    instruction_count = Nydp::Pair.new :instructions, vm.instructions.size
    arg_count         = Nydp::Pair.new :args,         vm.args.size
    vm.push_arg Nydp::Pair.from_list [context_count, instruction_count, arg_count]
  end
end
