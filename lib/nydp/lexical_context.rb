module Nydp
  class LexicalContext
    include Nydp::Helper
    attr_reader :names, :values, :parent

    def initialize parent
      @parent = parent
      @names  = []
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
      values[index] || Nydp::NIL
    end

    def set name, value
      names  << name
      values << value
    end

    def set_index index, value
      values[index] = value
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
