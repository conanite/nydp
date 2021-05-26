class Nydp::Builtin::VmInfo
  include Nydp::Builtin::Base, Singleton

  VMINFO_NS    = { }
  # CONTEXTS     = Nydp::Symbol.mk :contexts,     VMINFO_NS
  # INSTRUCTIONS = Nydp::Symbol.mk :instructions, VMINFO_NS
  # ARGS         = Nydp::Symbol.mk :args,         VMINFO_NS
  CONTEXTS     = :contexts
  INSTRUCTIONS = :instructions
  ARGS         = :args

  def builtin_invoke vm, args
    context_count     = Nydp::Pair.new CONTEXTS,     vm.contexts.size
    instruction_count = Nydp::Pair.new INSTRUCTIONS, vm.instructions.size
    arg_count         = Nydp::Pair.new ARGS,         vm.args.size
    vm.push_arg Nydp::Pair.from_list [context_count, instruction_count, arg_count]
  end
end
