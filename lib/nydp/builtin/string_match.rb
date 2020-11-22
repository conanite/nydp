class Nydp::Builtin::StringMatch
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    kmatch            = Nydp::Symbol.mk :match   , vm.ns
    kcaptures         = Nydp::Symbol.mk :captures, vm.ns
    target            = args.car.to_s
    pattern           = Regexp.new(args.cdr.car.to_s)
    match             = pattern.match target

    if match
      result             = Nydp::Hash.new
      result[kmatch]     = match.to_s
      result[kcaptures]  = Nydp::Pair.from_list match.captures.map { |cap| cap.to_s }
    else
      result             = Nydp::NIL
    end

    vm.push_arg result
  end
end
