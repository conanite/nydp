module Nydp::Builtin
  module Base
    include Nydp::Helper

    def builtin_invoke   vm, args       ; raise "#{self.class.name} : please implement #builtin_invoke" ; end
    def builtin_invoke_1 vm             ; builtin_invoke vm, Nydp::NIL                    ; end
    def builtin_invoke_2 vm, a          ; builtin_invoke vm, cons(a)                      ; end
    def builtin_invoke_3 vm, a0, a1     ; builtin_invoke vm, cons(a0, cons(a1))           ; end
    def builtin_invoke_4 vm, a0, a1, a2 ; builtin_invoke vm, cons(a0, cons(a1, cons(a2))) ; end

    def invoke_1 vm
      builtin_invoke_1 vm
    rescue StandardError => e
      handle_error e
    end

    def invoke_2 vm, arg
      builtin_invoke_2 vm, arg
    rescue StandardError => e
      handle_error e, arg
    end

    def invoke_3 vm, arg_0, arg_1
      builtin_invoke_3 vm, arg_0, arg_1
    rescue StandardError => e
      handle_error e, arg_0, arg_1
    end

    def invoke_4 vm, arg_0, arg_1, arg_2
      builtin_invoke_4 vm, arg_0, arg_1, arg_2
    rescue StandardError => e
      handle_error e, arg_0, arg_1, arg_2
    end

    # called from 'apply (among others)
    def invoke vm, args
      builtin_invoke vm, args
    rescue StandardError => e
      handle_error e, *(args.to_a)
    end

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
