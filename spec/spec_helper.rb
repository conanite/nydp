require 'nydp'
require 'nydp/symbol'

module SpecHelper
  def sym name
    Nydp::Symbol.mk name.to_sym, ns
  end

  def parse txt
    reader = Nydp::StringReader.new txt
    Nydp::Parser.new(ns).expression(Nydp::Tokeniser.new reader)
  end

  def pair_list xs, last=Nydp::NIL
    Nydp::Pair.from_list xs, last
  end

  def self.included base
    base.let(:ns)  { { } }
  end
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.include Nydp::Helper
  config.include SpecHelper
end
