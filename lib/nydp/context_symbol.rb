module Nydp
  class ContextSymbol
    def self.build depth, name, binding_index
      cname = "ContextSymbol_#{depth}_#{binding_index}"

      existing = const_get(cname) rescue nil
      return existing.new(name) if existing

      getctx = ([".parent"] * depth).join
      at_index = if binding_index < 5
                   "at_#{binding_index}"
                 else
                   "at_index(#{binding_index})"
                 end

      set_index = if binding_index < 5
                    "at_#{binding_index}= value"
                  else
                    "set_index(#{binding_index}, value)"
                  end

      klass = <<KLASS
class #{cname}
  def initialize name
    @name = name
  end

  def value ctx
    ctx#{getctx}.#{at_index} || Nydp::NIL
  end

  def assign value, ctx
    ctx#{getctx}.#{set_index}
  end

  def execute vm
    vm.push_arg value vm.current_context
  end

  def inspect ; to_s                               ; end
  def to_s    ; "[#{depth}##{binding_index}]\#{@name}" ; end
end
KLASS

      eval klass
      const_get(cname).new(name)
    end
  end
end
