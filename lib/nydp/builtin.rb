require 'nydp'
require 'nydp/error'

module Nydp::Builtin
  module Base
    include Nydp::Helper

    def invoke_1 vm
      invoke vm, Nydp.NIL
    end

    def invoke_2 vm, arg
      invoke vm, cons(arg)
    end

    def invoke_3 vm, arg_0, arg_1
      invoke vm, cons(arg_0, cons(arg_1))
    end

    def invoke vm, args
      builtin_invoke vm, args
    rescue Exception => e
      handle_error e, args
    end

    def handle_error e, args
      case e
      when Nydp::Error
        raise e
      else
        new_msg = "Called #{self.inspect}\nwith args #{args.inspect}\nraised\n#{Nydp.indent_text e.message}\nat #{e.backtrace.first}"
        raise $!, new_msg, $!.backtrace
      end
    end

    def name
      cname = self.class.name.split("::").last
      cname = cname.gsub(/([a-z])([A-Z])/) { |m| "#{m[0]}-#{m[1].downcase}" }
      cname = cname.gsub(/^([A-Z])/) { |m|  m.downcase }
      cname
    end

    def inspect   ; "builtin/#{name}" ; end
    def to_s      ; name              ; end
    def nydp_type ; "fn"              ; end
  end
end

Dir[File.join(File.dirname(__FILE__), "builtin", "**/*.rb")].each {|f|
  require f
}
