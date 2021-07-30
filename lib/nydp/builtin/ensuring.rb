# require "nydp/vm"

class Nydp::Builtin::Ensuring
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  def builtin_call ensureme, tricky
    begin
      tricky.call
    ensure
      ensureme.call
    end
  end
end
