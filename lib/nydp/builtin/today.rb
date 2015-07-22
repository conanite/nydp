class Nydp::Builtin::Today
  include Nydp::Helper

  def invoke vm, args
    vm.push_arg(Nydp::Date.new Date.today)
  end
end
