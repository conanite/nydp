class Nydp::Builtin::Puts
  include Nydp::Builtin::Base

  def builtin_invoke vm, args
    s = args.map { |a| a.to_s }
    puts s.join ' '
    vm.push_arg args.car
  end

  def name ; "p" ; end
end
