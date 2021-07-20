require 'nydp'
require 'nydp/symbol'

module SpecHelper
  def sym name
    # Nydp::Symbol.mk name.to_sym, ns
    name.to_s.to_sym
  end

  def parse txt
    Nydp.new_parser(ns).expression(Nydp.new_tokeniser Nydp::StringReader.new(txt))
  end

  def pair_list xs, last=Nydp::NIL
    Nydp::Pair.from_list xs, last
  end

  def self.included base
    base.let(:ns)  { Nydp::Namespace.new }
  end
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.include Nydp::Helper
  config.include SpecHelper
end

class TestThing
  attr_accessor :a, :b, :c
  def initialize a, b, c
    @a, @b, @c = a, b, c
  end

  def inspect
    "(TestThing #{a.inspect} #{b.inspect})"
  end

  def one_thing x
    x + a
  end

  def two_things x, y
    x + (y * b)
  end

  def _nydp_get name
    name = name.to_s.to_sym
    return send(name) if name == :a || name == :b
    return method(name) if name == :one_thing || name == :two_things
  end
end
