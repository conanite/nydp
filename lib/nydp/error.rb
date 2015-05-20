module Nydp
  def self.indent_text txt
    txt.split(/\n/).map { |line| "  #{line}"}.join("\n")
  end

  class Error < StandardError
  end
end
