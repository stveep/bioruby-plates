require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BioPlates" do
  context "reading data from a supplied CSV file" do
    it "reads data and checks for suitable headings" do
      expect{BioPlates.read("spec/fixtures/4x96.csv")}.not_to raise_error
      expect{BioPlates.read("spec/fixtures/rowname-error.csv")}.to raise_error(RuntimeError)
    end

    it "adds leading zeroes to Column strings" do
      p = BioPlates.read("spec/fixtures/4x96.csv")
      expect(p.first[1].wells.first.column).to eq "01"
    end

    it "converts Well to Row and Column if required" do
      p = BioPlates.read("spec/fixtures/emptyrowcol.csv")
      expect(p.first[1].wells.first.row).to eq "A"
      expect(p.first[1].wells.first.column).to eq "01"
    end

  end

  context "When fewer than four plates are supplied" do
    p96 = BioPlates.read("spec/fixtures/4x96.csv")
    p384 = BioPlates.read("spec/fixtures/384.csv")
    twoplates = {"Plate1" => p96["Plate1"].dup,"Plate2" => p96["Plate2"].dup}
    p384.first[1].wells.map(&:index!)
    it "warns and re-uses previous plates" do
      expect(BioPlates.quadrants(twoplates)).to receive(:warn)
    end
  end

  context "When four 96-well plates are supplied" do
    p96 = BioPlates.read("spec/fixtures/4x96.csv")
    p384 = BioPlates.read("spec/fixtures/384.csv")
    p384.first[1].wells.map(&:index!)
    it "Forms a new 384-well BioPlates::Plate object with correct well annotations" do
      expect(BioPlates.quadrants(p96).wells.map{|w| w.well}).to eq p384.first[1].wells.map{|w| w.well}
    end
  end
end
