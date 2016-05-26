class Nydp::Builtin::Puts
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    if Nydp::NIL.is? args
      puts
    else
      s = args.map { |a| a.to_s }
      puts s.join ' '
    end
    vm.push_arg args.car
  end

  def name ; "p" ; end
end
