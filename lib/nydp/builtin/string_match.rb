class Nydp::Builtin::StringMatch
  include Nydp::Builtin::Base

  def initialize ns
    @match    = Nydp::Symbol.mk :match   , ns
    @captures = Nydp::Symbol.mk :captures, ns
  end

  def builtin_invoke vm, args
    target            = args.car.to_s
    pattern           = Regexp.new(args.cdr.car.to_s)
    match             = pattern.match target

    if match
      result            = Nydp::Hash.new
      result[@match]    = Nydp::StringAtom.new match.to_s
      result[@captures] = Nydp::Pair.from_list match.captures.map { |cap| Nydp::StringAtom.new cap.to_s }
    else
      result            = Nydp.NIL
    end

    vm.push_arg result
  end
end
