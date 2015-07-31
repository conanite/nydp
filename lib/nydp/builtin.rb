require 'nydp'
require 'nydp/error'

module Nydp::Builtin
  module Base
    def invoke vm, args
      builtin_invoke vm, args
    rescue Exception => e
      new_msg = "Called #{self.inspect}\nwith args #{args}\nraised\n#{Nydp.indent_text e.message}"
      raise $!, new_msg, $!.backtrace
    end

    def name
      cname = self.class.name.split("::").last
      cname = cname.gsub(/([a-z])([A-Z])/) { |m| "#{m[0]}-#{m[1].downcase}" }
      cname = cname.gsub(/^([A-Z])/) { |m|  m.downcase }
      cname
    end

    def inspect ; "builtin/#{name}" ; end
    def to_s    ; name              ; end
  end
end

Dir[File.join(File.dirname(__FILE__), "builtin", "**/*.rb")].each {|f|
  require f
}
