require 'spec_helper'

describe Nydp::Date do

  let(:ns) { { } }

  it "converts ruby Date to Nydp::Date" do
    rd = Date.parse "2015-06-08"
    nd = Nydp.r2n rd, ns

    expect(nd).        to be_a Nydp::Date
    expect(nd.to_s).   to eq "2015-06-08"
    expect(nd.inspect).to eq "#<Date: 2015-06-08 ((2457182j,0s,0n),+0s,2299161j)>"
    expect(nd.to_ruby).to eq Date.parse("2015-06-08")
  end

  it "returns date components" do
    rd = Date.parse "2015-06-08"
    nd = Nydp.r2n rd, ns

    expect(nd[:year]). to eq 2015
    expect(nd[:month]).to eq 6
    expect(nd[:day]).  to eq 8
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
