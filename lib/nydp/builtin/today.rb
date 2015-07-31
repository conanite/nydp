class Nydp::Builtin::Today
  include Nydp::Helper, Nydp::Builtin::Base

  def builtin_invoke vm, args
    vm.push_arg(Nydp::Date.new Date.today)
  end
end
