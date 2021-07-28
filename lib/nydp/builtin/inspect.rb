class Nydp::Builtin::Inspect
  include Nydp::Builtin::Base, Singleton

  def builtin_call arg ; arg._nydp_inspect ; end
end
