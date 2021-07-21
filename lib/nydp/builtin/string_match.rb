class Nydp::Builtin::StringMatch
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    kmatch            = :match
    kcaptures         = :captures

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

    result
  end

  def builtin_call target, pattern
    target  = target.to_s
    pattern = Regexp.new(pattern.to_s) unless pattern.is_a? Regexp
    match   = pattern.match target

    if match
      { match: match.to_s, captures: (match.captures.map(&:to_s)._nydp_wrapper) }
    end
  end
end
