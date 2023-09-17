class Nydp::Builtin::RNG
  include Nydp::Builtin::Base, Singleton

  def builtin_call a0=nil
    if a0 == nil
      Random.new
    else
      Random.new(a0)
    end
  end
end

class ::Random
  include Nydp::Builtin::Base

  def builtin_call a0=nil, a1=nil
    if a0 == nil
      self.rand
    elsif a1 == nil
      self.rand(a0)
    else
      (a0 + self.rand(a1 - a0))
    end
  end
end
