class Nydp::Builtin::Log
  include Nydp::Builtin::Base, Singleton

  def builtin_call *args
    Nydp.logger.info(args.map(&:to_s).join(' '))
  end
end
