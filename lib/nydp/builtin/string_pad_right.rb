class Nydp::Builtin::StringPadRight
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke_4 vm, str, len, padding
    vm.push_arg str.to_s.ljust(len, padding.to_s)
  end
end
