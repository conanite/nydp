module Nydp
  def self.indent_text txt
    txt.split(/\n/).map { |line| "  #{line}"}.join("\n")
  end

  class Error < StandardError
    def initialize message, nydp_cause=nil
      super(message)
      @nydp_cause = nydp_cause
    end

    def cause
      @nydp_cause || super
    end
  end
end
