require 'spec_helper'

describe Nydp do

  def run txt
    Nydp.setup ns
    Nydp::Runner.new(ns, Nydp::StringReader.new("test", txt)).run
  end

  describe "unhandled_error" do
    it "raises a helpful error" do
      error = nil
      begin
        run "(/ 10 0)"
      rescue StandardError => e
        error = e
      end

      expect(error).to be_a Nydp::Error
      expect(error.message).to eq "failed to eval (/ 10 0) from src (/ 10 0)"

#       expect(error.cause).to be_a RuntimeError
#       expect(error.cause.message).to eq "Called builtin//
# with args
#   10
#   0"

      expect(error.cause).to be_a ZeroDivisionError
      expect(error.cause.message).to eq "divided by 0"
    end

    it "recovers quickly from an error" do
      run "dflkjdgjeirgjeoi"
      expect(run "(+ 2 3 4)").to eq 9
    end
  end
end
