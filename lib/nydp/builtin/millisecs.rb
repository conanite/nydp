class Nydp::Builtin::Millisecs
  include Nydp::Helper

  def invoke vm, args
    vm.push_arg (Time.now.to_f * 1000).to_i
  end
end
