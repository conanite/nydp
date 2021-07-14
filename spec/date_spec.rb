require 'spec_helper'

describe Nydp::Date do

  let(:ns) { { }               }
  let(:vm) { Nydp::VM.new(ns)  }

  it "converts ruby Date to Nydp::Date" do
    rd = Date.parse "2015-06-08"
    nd = Nydp.r2n rd

    expect(nd).        to be_a Nydp::Date
    expect(nd.to_s).   to eq "2015-06-08"
    expect(nd._nydp_inspect).to eq "#<Date: 2015-06-08 ((2457182j,0s,0n),+0s,2299161j)>"
    expect(nd.to_ruby).to eq Date.parse("2015-06-08")
  end

  it "creates a new date" do
    df = Nydp::Builtin::Date.instance
    nd = df.invoke_4 vm, 2015, 11, 18
    # nd = vm.args.pop
    expect(nd).to be_a Nydp::Date
    expect(nd.ruby_date).to eq Date.parse("2015-11-18")
  end

  it "returns today" do
    df = Nydp::Builtin::Date.instance
    nd = df.invoke_1 vm
    # nd = vm.args.pop
    expect(nd).to be_a Nydp::Date
    expect(nd.ruby_date).to eq Date.today
  end

  it "returns date components" do
    rd = Date.parse "2015-06-08"
    nd = Nydp.r2n rd

    expect(nd._nydp_get(:year) ).to eq 2015
    expect(nd._nydp_get(:month)).to eq 6
    expect(nd._nydp_get(:day)  ).to eq 8
  end

  describe "date maths" do
    let(:d0) { Nydp.r2n Date.today       }
    let(:d1) { Nydp.r2n (Date.today + 6) }

    it "works with builtin minus" do
      minus = Nydp::Builtin::Minus.instance

      diff = minus.invoke vm, pair_list([d1, d0])
      # diff = vm.args.pop

      expect(d0).to be_a Nydp::Date
      expect(diff).to eq 6
    end

    describe "'>" do
      it "works with builtin greater-than when true" do
        f = Nydp::Builtin::GreaterThan.instance

        a = f.invoke vm, pair_list([d1, d0])

        expect(a).to eq d0
      end

      it "compares with nil" do
        f = Nydp::Builtin::GreaterThan.instance

        a = f.invoke vm, pair_list([d1, Nydp::NIL])

        expect(a).to eq Nydp::NIL
      end

      it "works with builtin greater-than when false" do
        f = Nydp::Builtin::GreaterThan.instance

        a = f.invoke vm, pair_list([d0, d1])

        expect(a).to eq Nydp::NIL
      end
    end

    describe "'<" do
      it "works with builtin less-than when true" do
        f = Nydp::Builtin::LessThan.instance

        a = f.invoke vm, pair_list([d0, d1])

        expect(a).to eq d1
      end

      it "works with builtin less-than when false" do
        f = Nydp::Builtin::LessThan.instance

        a = f.invoke vm, pair_list([d1, d0])

        expect(a).to eq Nydp::NIL
      end

      it "compares with nil" do
        f = Nydp::Builtin::LessThan.instance

        a = f.invoke vm, pair_list([d1, Nydp::NIL])

        expect(a).to eq Nydp::NIL
      end
    end

    it "works with builtin plus" do
      plus = Nydp::Builtin::Plus.instance

      sum = plus.invoke vm, pair_list([d0, 5])
      # sum = vm.args.pop

      expect(d0) .to be_a Nydp::Date
      expect(sum).to be_a Nydp::Date
      expect(sum.ruby_date).to eq(Date.today + 5)
    end
  end

  it "returns relative dates by year" do
    rd = Date.parse "2015-06-08"
    nd = Nydp.r2n rd

    expect(nd._nydp_get(:"last-year").to_s).          to eq "2014-06-08"
    expect(nd._nydp_get(:"next-year").to_s).          to eq "2016-06-08"
    expect(nd._nydp_get(:"beginning-of-year").to_s).  to eq "2015-01-01"
    expect(nd._nydp_get(:"end-of-year").to_s).        to eq "2015-12-31"
  end

  it "returns relative dates by month" do
    rd = Date.parse "2015-06-08"
    nd = Nydp.r2n rd

    expect(nd._nydp_get(:"last-month").to_s).          to eq "2015-05-08"
    expect(nd._nydp_get(:"next-month").to_s).          to eq "2015-07-08"
    expect(nd._nydp_get(:"beginning-of-month").to_s).  to eq "2015-06-01"
    expect(nd._nydp_get(:"end-of-month").to_s).        to eq "2015-06-30"
  end

  it "calculates end-of-month all year around" do
    expect(Nydp.r2n(Date.parse("2015-01-08"))._nydp_get(:"end-of-month").to_s).to eq "2015-01-31"
    expect(Nydp.r2n(Date.parse("2015-02-08"))._nydp_get(:"end-of-month").to_s).to eq "2015-02-28"
    expect(Nydp.r2n(Date.parse("2016-02-08"))._nydp_get(:"end-of-month").to_s).to eq "2016-02-29"
    expect(Nydp.r2n(Date.parse("2015-03-08"))._nydp_get(:"end-of-month").to_s).to eq "2015-03-31"
    expect(Nydp.r2n(Date.parse("2015-04-08"))._nydp_get(:"end-of-month").to_s).to eq "2015-04-30"
    expect(Nydp.r2n(Date.parse("2015-05-08"))._nydp_get(:"end-of-month").to_s).to eq "2015-05-31"
    expect(Nydp.r2n(Date.parse("2015-06-08"))._nydp_get(:"end-of-month").to_s).to eq "2015-06-30"
    expect(Nydp.r2n(Date.parse("2015-07-08"))._nydp_get(:"end-of-month").to_s).to eq "2015-07-31"
    expect(Nydp.r2n(Date.parse("2015-08-08"))._nydp_get(:"end-of-month").to_s).to eq "2015-08-31"
    expect(Nydp.r2n(Date.parse("2015-09-08"))._nydp_get(:"end-of-month").to_s).to eq "2015-09-30"
    expect(Nydp.r2n(Date.parse("2015-10-08"))._nydp_get(:"end-of-month").to_s).to eq "2015-10-31"
    expect(Nydp.r2n(Date.parse("2015-11-08"))._nydp_get(:"end-of-month").to_s).to eq "2015-11-30"
    expect(Nydp.r2n(Date.parse("2015-12-08"))._nydp_get(:"end-of-month").to_s).to eq "2015-12-31"
  end

  it "manages leap years" do
    rd = Date.parse "2020-02-08"
    nd = Nydp.r2n rd

    expect(nd._nydp_get(:"last-month").to_s).          to eq "2020-01-08"
    expect(nd._nydp_get(:"next-month").to_s).          to eq "2020-03-08"
    expect(nd._nydp_get(:"beginning-of-month").to_s).  to eq "2020-02-01"
    expect(nd._nydp_get(:"end-of-month").to_s).        to eq "2020-02-29"

    rd = Date.parse "2020-02-28"
    nd = Nydp.r2n rd
    expect(nd._nydp_get(:"tomorrow").to_s).            to eq "2020-02-29"

    rd = Date.parse "2020-03-01"
    nd = Nydp.r2n rd
    expect(nd._nydp_get(:"yesterday").to_s).           to eq "2020-02-29"
  end

  it "returns relative dates by week" do
    rd = Date.parse "2015-03-12"
    nd = Nydp.r2n rd

    expect(nd._nydp_get(:"last-week").to_s).          to eq "2015-03-05"
    expect(nd._nydp_get(:"next-week").to_s).          to eq "2015-03-19"
    expect(nd._nydp_get(:"beginning-of-week").to_s).  to eq "2015-03-09"
    expect(nd._nydp_get(:"end-of-week").to_s).        to eq "2015-03-15"
  end

  it "returns age relative to today" do
    rd = Date.parse "2014-03-12"
    nd = Nydp.r2n rd
    allow(::Date).to receive_messages(today: Date.parse("2016-06-21"))
    expect(nd._nydp_get(:age)).to eq({ years: 2, months: 3 })
  end

  it "returns a negative age relative to today for a date in the future" do
    rd = Date.parse "2094-11-18"
    nd = Nydp.r2n rd
    allow(::Date).to receive_messages(today: Date.parse("2016-06-21"))
    expect(nd._nydp_get(:age)).to eq({ years: -78, months: -5 })
  end

  describe "#change" do
    let(:nd) { Nydp::Date.new(Date.parse("1965-06-08")) }

    it "advances by weeks" do
      expect((nd.change  1, :week).to_s).to eq "1965-06-15"
      expect((nd.change -1, :week).to_s).to eq "1965-06-01"
      expect((nd.change -2, :week).to_s).to eq "1965-05-25"
      expect((nd.change  2, :week).to_s).to eq "1965-06-22"
    end

    it "advances by days" do
      expect((nd.change  1, :day).to_s).to eq "1965-06-09"
      expect((nd.change -1, :day).to_s).to eq "1965-06-07"
      expect((nd.change -2, :day).to_s).to eq "1965-06-06"
      expect((nd.change  2, :day).to_s).to eq "1965-06-10"
    end

    it "advances by months" do
      expect((nd.change  1, :month).to_s).to eq "1965-07-08"
      expect((nd.change -1, :month).to_s).to eq "1965-05-08"
      expect((nd.change -2, :month).to_s).to eq "1965-04-08"
      expect((nd.change  2, :month).to_s).to eq "1965-08-08"
    end

    it "advances by years" do
      expect((nd.change  1, :year).to_s).to eq "1966-06-08"
      expect((nd.change -1, :year).to_s).to eq "1964-06-08"
      expect((nd.change -2, :year).to_s).to eq "1963-06-08"
      expect((nd.change  2, :year).to_s).to eq "1967-06-08"
    end

    it "handles leap years and small months" do
      d = Nydp::Date.new(Date.parse("2019-12-31"))

      expect(d.change( 2, :month).to_s).to eq "2020-02-29"
      expect(d.change(12, :month).to_s).to eq "2020-12-31"
      expect(d.change(14, :month).to_s).to eq "2021-02-28"
      expect(d.change( 6, :month).to_s).to eq "2020-06-30"
      expect(d.change( 7, :month).to_s).to eq "2020-07-31"

      d = Nydp::Date.new(Date.parse("2020-02-29"))
      expect(d.change(12, :month).to_s).to eq "2021-02-28"
    end
  end
end
