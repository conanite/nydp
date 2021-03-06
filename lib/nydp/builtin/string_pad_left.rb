class Nydp::Builtin::StringPadLeft
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke_4 vm, str, len, padding
    vm.push_arg str.to_s.rjust(len, padding.to_s)
  end
end
