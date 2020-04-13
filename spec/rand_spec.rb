require "spec_helper"

describe Nydp::Builtin::Rand do
  let(:vm) { Nydp::VM.new(ns) }

  let(:randf) { Nydp::Builtin::Rand.instance }

  def get_rand *args
    randf.invoke vm, pair_list(args)
    vm.pop_args(1).first
  end

  describe "zero args" do
    it "returns values between 0 and 1" do
      numbers = (0..100).map { |i| get_rand }
      expect(numbers.all? { |n| n >= 0 && n < 1 })
      avg = numbers.reduce &:+
      expect(avg).to be_between 40, 60 # with high probability
      distinct = Set.new numbers
      expect(distinct.count).to be > 90
    end
  end

  describe "one arg" do
    it "returns values between 0 and arg" do
      numbers = (0..200).map { |i| get_rand 10 }
      expect(numbers.all? { |n| n >= 0 && n < 10 })
      avg = numbers.reduce &:+
      expect(avg).to be_between 800, 1200 # with high probability
      distinct = Set.new numbers
      expect(distinct.count).to eq 10
    end
  end

  describe "two arg" do
    it "returns values between arg 0 and arg 1" do
      numbers = (0..200).map { |i| get_rand 10, 20 }
      expect(numbers.all? { |n| n >= 10 && n < 20 })
      avg = numbers.reduce &:+
      expect(avg).to be_between 2800, 3200 # with high probability
      distinct = Set.new numbers
      expect(distinct.count).to eq 10
    end
  end
end
