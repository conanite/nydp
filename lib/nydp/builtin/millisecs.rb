class Nydp::Builtin::Millisecs
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    vm.push_arg (Time.now.to_f * 1000).to_i
  end
end
