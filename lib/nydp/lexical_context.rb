module Nydp
  class LexicalContext
    include Nydp::Helper
    attr_reader :values, :parent
    attr_accessor :at_0, :at_1, :at_2, :at_3, :at_4

    def initialize parent
      @parent = parent
      @values = []
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
      index < 5 ? send(:"at_#{index}") : values[index]
    end

    def set_index index, value
      if (index < 5)
        send(:"at_#{index}=", value)
      else
        values[index] = value
      end
    end

    def to_s_with_indent str
      me = @values.map { |k, v|
        [str, k, "=>", v].join ' '
      }.join "\n"
      me + (parent ? parent.to_s_with_indent("  #{str}") : '')
    end

    def to_s
      to_s_with_indent ''
    end
  end
end
