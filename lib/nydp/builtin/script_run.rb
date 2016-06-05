class Nydp::Builtin::ScriptRun
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    builtin_invoke_3 vm, args.car, args.cdr.car
  end

  def builtin_invoke_3 vm, event, name
    puts "script-run: #{event.inspect} #{name.inspect}"
    script_sym = Nydp::Symbol.mk :"script-name", vm.ns
    plugin_sym = Nydp::Symbol.mk :"script-name", vm.ns
    case event.to_sym
    when :"script-start"
      script_sym.assign(name)
    when :"script-end"
      script_sym.assign(Nydp::NIL)
    when :"plugin-start"
      plugin_sym.assign(name)
    when :"plugin-end"
      plugin_sym.assign(Nydp::NIL)
    end
    vm.push_arg name
  end
end
