require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'fakefs/spec_helpers'

describe BioPlates::Annotator do

  it "reads an annotation file into R as variable annofile" do
    BioPlates::Annotator.read("spec/fixtures/annotation.txt")
    expect {R.eval "annofile"}.to output(/annofile
\s+Plate\s+Area\s+Condition\s+Value
1\s+1\s+A1-B12\s+siRNA\s+PLK1
2\s+1\s+A1-B6\s+drug\s+olaparib
3\s+1\s+A7-B12\s+drug\s+DMSO
4\s+2\s+A1-B12\s+siRNA\s+siCON1
5\s+2\s+A1-B6\s+drug\s+olaparib
6\s+2\s+A7-B12\s+drug\s+DMSO
7\s+3\s+A1-B12\s+siRNA\s+Allstar
8\s+3\s+A1-B6\s+drug\s+olaparib
9\s+3\s+A7-B12\s+drug\s+DMSO
10\s+4\s+A1-B12\s+siRNA\s+BRCA1
11\s+4\s+A1-B6\s+drug\s+olaparib
12\s+4\s+A7-B12\s+drug\s+DMSO
13\s+5\s+A1-AF23\s+drug\s+steves\s+drug/).to_stdout

  end

  it "reads an excel annotation file into R" do
    BioPlates::Annotator.read("spec/fixtures/annotation.xlsx")
    expect {R.eval "annofile"}.to output(/annofile
\s+Plate\s+Area\s+Condition\s+Value
1\s+1\s+A1-B12\s+siRNA\s+PLK1
2\s+1\s+A1-B6\s+drug\s+olaparib
3\s+1\s+A7-B12\s+drug\s+DMSO
4\s+2\s+A1-B12\s+siRNA\s+siCON1
5\s+2\s+A1-B6\s+drug\s+olaparib
6\s+2\s+A7-B12\s+drug\s+DMSO
7\s+3\s+A1-B12\s+siRNA\s+Allstar
8\s+3\s+A1-B6\s+drug\s+olaparib
9\s+3\s+A7-B12\s+drug\s+DMSO
10\s+4\s+A1-B12\s+siRNA\s+BRCA1
11\s+4\s+A1-B6\s+drug\s+olaparib
12\s+4\s+A7-B12\s+drug\s+DMSO
13\s+5\s+A1-AF23\s+drug\s+steves\s+drug/).to_stdout

  end

  it "calls the annotation R script and outputs an annotation file" do
    include FakeFS::SpecHelpers
    BioPlates::Annotator.annotate("spec/fixtures/annotation.txt","spec/tmp/anno-output.csv")
    output = File.open("spec/tmp/anno-output.csv","r").each
    expect(output.next.chomp).to eq "Row,Column,Plate,siRNA,drug,Well"
    expect(output.next.chomp).to eq "A,1,1,PLK1,olaparib,A01"
  end

end
