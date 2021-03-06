class Nydp::Builtin::Error
  include Nydp::Builtin::Base, Singleton

  # override #invoke on nydp/builtin/base because
  # we don't want to inherit error handling
  def builtin_invoke vm, args
    raise Nydp::Error.new(args.to_a.map(&:to_s).join("\n"), vm.last_error)
  end
end
