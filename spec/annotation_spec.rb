require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'fakefs/spec_helpers'

describe BioPlates::Annotator do

  it "reads an annotation file into R as variable annofile" do
    f = BioPlates::Annotator.read("spec/fixtures/annotation.txt")
    expect {R.eval "annofile"}.to output(/annofile
   Plate   Area Condition    Value
1      1 A1-B12     siRNA     PLK1
2      1  A1-B6      drug olaparib
3      1 A7-B12      drug     DMSO
4      2 A1-B12     siRNA   siCON1
5      2  A1-B6      drug olaparib
6      2 A7-B12      drug     DMSO
7      3 A1-B12     siRNA  Allstar
8      3  A1-B6      drug olaparib
9      3 A7-B12      drug     DMSO
10     4 A1-B12     siRNA    BRCA1
11     4  A1-B6      drug olaparib
12     4 A7-B12      drug     DMSO/).to_stdout

  end

  it "calls the annotation R script and outputs an annotation file" do
    include FakeFS::SpecHelpers
    BioPlates::Annotator.annotate("spec/fixtures/annotation.txt","spec/tmp/anno-output.csv")
    output = File.open("spec/tmp/anno-output.csv","r").each
    expect(output.next.chomp).to eq "Row,Column,Plate,siRNA,drug,Well"
    expect(output.next.chomp).to eq "A,1,1,PLK1,olaparib,A01"
  end

end
