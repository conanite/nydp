require 'nydp'

module Nydp::Builtin
  module Base
    def indent_text txt
      txt.split(/\n/).map { |line| "  #{line}"}.join("\n")
    end

    def invoke vm, args
      builtin_invoke vm, args
    rescue Exception => e
      new_msg = "Invoking #{self.class.name}\nwith args #{args}\nraised\n#{indent_text e.message}"
      raise $!, new_msg, $!.backtrace
    end
  end

  def inspect ; self.class.name ; end
  def to_s    ; self.class.name ; end
end

Dir[File.join(File.dirname(__FILE__), "builtin", "**/*.rb")].each {|f|
  require f
}
