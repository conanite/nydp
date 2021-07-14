class Nydp::Builtin::RubyWrap
  @@builtins           = { }

  def self.builtins
    @@builtins
  end

  class Coder < Struct.new(:name, :size, :code, :helpers)
    def msize ; size + 1 ; end

    def arg_mapper
      case size
      when 0 ; ""
      when 1 ; ", a0"
      when 2 ; ", a0, a1"
      when 3 ; ", a0, a1, a2"
      when 4 ; ", a0, a1, a2, a3"
      when 5 ; ", a0, a1, a2, a3, a4"
      else   ; raise "maximum 5 arguments!"
      end
    end

    def to_ruby
      generic_code = code.
                       gsub(/a0/, "args.car").
                       gsub(/a1/, "args.cdr.car").
                       gsub(/a2/, "args.cdr.cdr.car").
                       gsub(/a3/, "args.cdr.cdr.cdr.car").
                       gsub(/a4/, "args.cdr.cdr.cdr.cdr.car")
      <<CODE
class #{name}
  include Nydp::Builtin::Base, Singleton#{helpers}

  def builtin_invoke_#{msize} vm#{ arg_mapper }
    (#{code})
  end

  def builtin_invoke vm, args
    (#{generic_code})
  end

  # return the ruby equivalent of this code if it was inlined inside another builtin
  def inline_code arg_expressions
    #{code.inspect}.
      gsub(/a0/, arg_expressions[0]).
      gsub(/a1/, arg_expressions[1]).
      gsub(/a2/, arg_expressions[2]).
      gsub(/a3/, arg_expressions[3]).
      gsub(/a4/, arg_expressions[4])
  end
end
CODE
    end
  end

  def self.const_missing const
    coder = @@builtins[const]
    coder ? class_eval(coder.to_ruby) : super
    const_get const
  end

  class WrapperBuilder
    def initialize default_helpers
      @default_helpers = default_helpers.to_s.strip != "" ? ", #{default_helpers}" : ""
    end

    def build name, args, code, helpers=""
      extra_helpers = helpers.to_s.strip != "" ? ", #{helpers}" : ""
      Nydp::Builtin::RubyWrap.builtins[name.to_sym] = Coder.new(name.to_sym, args, code, "#{@default_helpers}#{extra_helpers}")
    end
  end

  def self.builder includes
    WrapperBuilder.new(includes)
  end

  core_builder = builder ""
  core_builder.build(:Cons, 2, %{ Nydp::Pair.new(a0, a1) }        )
  core_builder.build(:Car , 1, %{ a0.car }                        )
  core_builder.build(:Cdr , 1, %{ a0.cdr }                        )
  core_builder.build(:Log , 1, %{ r2n Nydp.logger.info(a0.to_s) } )
end
