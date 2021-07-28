class Nydp::Builtin::Minus
  include Nydp::Builtin::Base, Singleton

  def name ; "-" ; end

  def builtin_call *args
    if args.length == 1
      - args.first
    elsif args.first
      args.reduce(&:-)
    else
      0
    end
  end
end
