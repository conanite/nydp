class Nydp::Builtin::Error
  include Nydp::Builtin::Base, Singleton

  def builtin_call *args
    raise Nydp::Error.new(args.map(&:to_s).join("\n"))
  end
end
