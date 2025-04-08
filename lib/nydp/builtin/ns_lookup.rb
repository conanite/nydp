class Nydp::Builtin::NsLookup
  include Nydp::Builtin::Base

  def initialize ns
    @ns = ns
    super()
  end

  def builtin_call name
    @ns.fetch name
  end
end
