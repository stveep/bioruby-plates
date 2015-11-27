require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe BioPlates::Plate do


  context "accessing wells by row and column" do
    before(:all) do
      p96 = BioPlates.read("spec/fixtures/4x96.csv")
      @plate = p96["Plate1"]
    end
    it "returns a hash of arrays of well object, by column" do
      expect(@plate.columns.class).to be Hash
      expect(@plate.columns.first[1][0].class).to be BioPlates::Plate::Well
    end
    it "returns an array of rows" do
      expect(@plate.rows.class).to be Hash
      expect(@plate.rows.first[1][0].class).to be BioPlates::Plate::Well
    end
  end

  context "adding leading zeroes to wells" do
    before(:all) do
      p96 = BioPlates.read("spec/fixtures/4x96.csv")
      @plate = p96["Plate1"]
    end
    it "adds a zero if the column has only one digit" do
      @plate.wells[1].column = 1
      @plate.add_leading_zeroes!
      expect(@plate.wells[1].column).to eq "01"
    end
    it "doesn't add a zero to two digit numbers" do
      @plate.wells[10].column = 10
      @plate.add_leading_zeroes!
      expect(@plate.wells[10].column).to eq "10"
    end
  end

  context "output" do
    before(:all) do
      p96 = BioPlates.read("spec/fixtures/4x96.csv")
      @plate = p96["Plate1"]
    end
    it "outputs a CSV file" do
      expect(CSV).to receive(:open)
      @plate.dump
    end
    it "includes arbitrary well annotations" do
      expect(csv).to receive(:add_row).with ["Plate","Row","Column","Drug","Conc"]
      @plate.dump
    end
  end
end
