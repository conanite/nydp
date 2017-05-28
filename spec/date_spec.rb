require 'spec_helper'

describe Nydp::Date do

  let(:ns) { { }               }
  let(:vm) { Nydp::VM.new(ns)  }

  it "converts ruby Date to Nydp::Date" do
    rd = Date.parse "2015-06-08"
    nd = Nydp.r2n rd, ns

    expect(nd).        to be_a Nydp::Date
    expect(nd.to_s).   to eq "2015-06-08"
    expect(nd.inspect).to eq "#<Date: 2015-06-08 ((2457182j,0s,0n),+0s,2299161j)>"
    expect(nd.to_ruby).to eq Date.parse("2015-06-08")
  end

  it "creates a new date" do
    df = Nydp::Builtin::Date.instance
    df.invoke_4 vm, 2015, 11, 18
    nd = vm.args.pop
    expect(nd).to be_a Nydp::Date
    expect(nd.ruby_date).to eq Date.parse("2015-11-18")
  end

  it "returns today" do
    df = Nydp::Builtin::Date.instance
    df.invoke_1 vm
    nd = vm.args.pop
    expect(nd).to be_a Nydp::Date
    expect(nd.ruby_date).to eq Date.today
  end

  it "returns date components" do
    rd = Date.parse "2015-06-08"
    nd = Nydp.r2n rd, ns

    expect(nd[:year]). to eq 2015
    expect(nd[:month]).to eq 6
    expect(nd[:day]).  to eq 8
  end

  describe "date maths" do
    let(:d0) { Nydp.r2n Date.today, ns       }
    let(:d1) { Nydp.r2n (Date.today + 6), ns }

    it "works with builtin minus" do
      minus = Nydp::Builtin::Minus.instance

      minus.invoke vm, pair_list([d1, d0])
      diff = vm.args.pop

      expect(d0).to be_a Nydp::Date
      expect(diff).to eq 6
    end

    describe "'>" do
      it "works with builtin greater-than when true" do
        f = Nydp::Builtin::GreaterThan.instance

        f.invoke vm, pair_list([d1, d0])

        expect(vm.args.pop).to eq d0
      end

      it "compares with nil" do
        f = Nydp::Builtin::GreaterThan.instance

        f.invoke vm, pair_list([d1, Nydp::NIL])

        expect(vm.args.pop).to eq Nydp::NIL
      end

      it "works with builtin greater-than when false" do
        f = Nydp::Builtin::GreaterThan.instance

        f.invoke vm, pair_list([d0, d1])

        expect(vm.args.pop).to eq Nydp::NIL
      end
    end

    describe "'<" do
      it "works with builtin less-than when true" do
        f = Nydp::Builtin::LessThan.instance

        f.invoke vm, pair_list([d0, d1])

        expect(vm.args.pop).to eq d1
      end

      it "works with builtin less-than when false" do
        f = Nydp::Builtin::LessThan.instance

        f.invoke vm, pair_list([d1, d0])

        expect(vm.args.pop).to eq Nydp::NIL
      end

      it "compares with nil" do
        f = Nydp::Builtin::LessThan.instance

        f.invoke vm, pair_list([d1, Nydp::NIL])

        expect(vm.args.pop).to eq Nydp::NIL
      end
    end

    it "works with builtin plus" do
      plus = Nydp::Builtin::Plus.instance

      plus.invoke vm, pair_list([d0, 5])
      sum = vm.args.pop

      expect(d0) .to be_a Nydp::Date
      expect(sum).to be_a Nydp::Date
      expect(sum.ruby_date).to eq(Date.today + 5)
    end
  end

  it "returns relative dates by year" do
    rd = Date.parse "2015-06-08"
    nd = Nydp.r2n rd, ns

    expect(nd[:"last-year"].to_s).          to eq "2014-06-08"
    expect(nd[:"next-year"].to_s).          to eq "2016-06-08"
    expect(nd[:"beginning-of-year"].to_s).  to eq "2015-01-01"
    expect(nd[:"end-of-year"].to_s).        to eq "2015-12-31"
  end

  it "returns relative dates by month" do
    rd = Date.parse "2015-06-08"
    nd = Nydp.r2n rd, ns

    expect(nd[:"last-month"].to_s).          to eq "2015-05-08"
    expect(nd[:"next-month"].to_s).          to eq "2015-07-08"
    expect(nd[:"beginning-of-month"].to_s).  to eq "2015-06-01"
    expect(nd[:"end-of-month"].to_s).        to eq "2015-06-30"
  end

  it "returns relative dates by week" do
    rd = Date.parse "2015-03-12"
    nd = Nydp.r2n rd, ns

    expect(nd[:"last-week"].to_s).          to eq "2015-03-05"
    expect(nd[:"next-week"].to_s).          to eq "2015-03-19"
    expect(nd[:"beginning-of-week"].to_s).  to eq "2015-03-09"
    expect(nd[:"end-of-week"].to_s).        to eq "2015-03-15"
  end
end
