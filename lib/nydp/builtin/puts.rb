class Nydp::Builtin::Puts
  include Nydp::Builtin::Base, Singleton

  def builtin_call *args
    s = args.map { |a| a.to_s }
    puts s.join ' '
    args.first
  end

  def name ; "p" ; end
end
