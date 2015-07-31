class Nydp::Builtin::Error
  include Nydp::Builtin::Base

  # override #invoke on nydp/builtin/base because
  # we don't want to inherit error handling
  def builtin_invoke vm, args
    raise Nydp::Error.new(args.inspect)
  end
end
