module Nydp
  class LexicalContext
    include Nydp::Helper
    attr_reader :parent
    attr_accessor :at_0, :at_1, :at_2, :at_3, :at_4, :at_5, :at_6, :at_7, :at_8, :at_9

    def initialize parent
      @parent = parent
    end

    def nth n
      case n
      when 0
        self
      when -1
        raise "wrong nesting level"
      else
        parent.nth(n - 1)
      end
    end

    def at_index index
      instance_variable_get :"@at_#{index}"
    end

    def set_index index, value
      instance_variable_set :"@at_#{index}", value
    end

    def method_missing mname, *args
      if mname.to_s =~ /at_\d+=/
        instance_variable_set :"@#{mname.to_s.sub(/=/, '')}", args[0]
      elsif mname.to_s =~ /at_\d+/
        instance_variable_get :"@#{mname}"
      else
        super
      end
    end

    def to_s_with_indent str
      me = (@values || { }).map { |k, v|
        [str, k, "=>", v].join ' '
      }.join "\n"
      me + (parent ? parent.to_s_with_indent("  #{str}") : '')
    end

    def pretty
      to_s_with_indent ''
    end

    def to_s
      values = []
      n = 0
      while at_index n
        values << at_index(n).inspect
        n += 1
      end
      parent_s = parent ? " parent #{parent.to_s}" : ""
      "(context (#{values.join ' '})#{parent_s})"
    end
  end
end
