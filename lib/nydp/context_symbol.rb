module Nydp
  class ContextSymbol
    def self.const_missing const
      if const.to_s =~ /^ContextSymbol_\d+_\d+$/
        name          = const.to_s.split(/_/)
        define_klass(const, name[1].to_i, name[2].to_i)
        const_get const
      else
        super(const)
      end
    end

    def self.define_klass name, depth, binding_index
      getctx = ([".parent"] * depth).join
      at_index = if binding_index < 10
                   "at_#{binding_index}"
                 else
                   "at_index(#{binding_index})"
                 end

      set_index = if binding_index < 10
                    "at_#{binding_index}= value"
                  else
                    "set_index(#{binding_index}, value)"
                  end

      code = <<-KLASS
        def initialize name, lexical_depth
          @name, @lexical_depth = name, lexical_depth
        end

        def lexical_reach n
          @lexical_depth + n
        end

        def compile_to_ruby
          "_arg_\#{@name.to_s._nydp_name_to_rb_name}"
        end

        def value ctx
          ctx#{getctx}.#{at_index} || Nydp::NIL
        rescue
          raise "failed looking up \#{@name._nydp_inspect} (\#{@name.class.name})"
        end

        def assign value, ctx
          ctx#{getctx}.#{set_index}
        rescue StandardError => e
          raise "problem in \#{self.class.name}#assign, name is \#{@name}, depth is \#{depth}, index is #{binding_index}"
        end

        def execute vm
          vm.push_arg value vm.current_context
        end

        def depth   ; #{depth}                               ; end
        def inspect ; to_s                                   ; end
        def to_s    ; "[#{depth}##{binding_index}#\#{@lexical_depth}]\#{@name}" ; end
      KLASS

      const_set name, Class.new(Nydp::ContextSymbol) {
        eval code, binding, name.to_s, 0
      }
    end

    def self.build effective_depth, name, binding_index, lexical_depth
      const_get(:"ContextSymbol_#{effective_depth}_#{binding_index}").new(name, lexical_depth)
    rescue
      raise "building ContextSymbol #{[effective_depth, name, binding_index, lexical_depth]._nydp_inspect}"
    end
  end
end
