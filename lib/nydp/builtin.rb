module Nydp::Builtin
  module Base
    include Nydp::Helper

    def handle_error e, *args
      case e
      when Nydp::Error
        raise e
      else
        arg_msg = args.map { |a| "  #{a._nydp_inspect}"}.join("\n")
        new_msg = "Called #{self._nydp_inspect}\nwith args\n#{arg_msg}"
        raise new_msg
      end
    end

    def call *args
      builtin_call *args
    rescue => e
      handle_error e, *args
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
