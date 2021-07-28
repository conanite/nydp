class Nydp::Builtin::StringMatch
  include Nydp::Builtin::Base, Singleton

  def builtin_call target, pattern
    target  = target.to_s
    pattern = Regexp.new(pattern.to_s) unless pattern.is_a? Regexp
    match   = pattern.match target

    if match
      { match: match.to_s, captures: (match.captures.map(&:to_s)._nydp_wrapper) }
    end
  end
end
