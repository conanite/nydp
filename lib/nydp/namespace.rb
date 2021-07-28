module Nydp
  class Namespace
    include Nydp::Helper

    def method_missing name, *args
      if name.to_s =~ /^ns_/
        attr = name.to_s.gsub(/=$/, '').to_sym
        singleton_class.instance_eval do
          attr_accessor attr
        end
        send name, *args
      else
        super
      end
    end

    def names
      mm = methods.select { |m| m.to_s =~ /^ns_.*[^=]$/ }.map { |m| nydp_name(m).to_sym }
    end

    def nydp_name n
      n.to_s.gsub(/^ns_/, '').gsub(/_../) { |ch| ch[1,2].to_i(16).chr }
    end

    def ruby_name n
      n.to_s._nydp_name_to_rb_name
    end

    def assign name, value
      send "ns_#{ruby_name name}=", value
    end

    def fetch name
      send "ns_#{ruby_name name}"
    end

    def apply name, *args
      fn = if name.is_a?(String) || name.is_a?(::Symbol)
             fetch name
           elsif name.respond_to? :call
             name
           end

      raise "can't apply #{name.inspect} : not a function" unless fn && fn.respond_to?(:call)

      fn.call *(args.map { |a| r2n a })

    rescue StandardError => e
      raise Nydp::Error.new("Invoking #{name}\nwith args (#{args.map(&:_nydp_compact_inspect).join(' ')})")
    end
  end
end
