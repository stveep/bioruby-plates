# bio-plates

[![Build Status](https://secure.travis-ci.org/stveep/bioruby-plates.png)](http://travis-ci.org/stveep/bioruby-plates)

Full description goes here

Note: this software is under active development!

## Installation

```sh
gem install bioruby-plates
```

## Usage
Command line (currently only rearrangement of 96-well plates into a 384-well plate in quadrants):

```sh
gem install bioruby-plates

bioplates example
bioplates quadrants [--output=output.csv --newname='My Plate'] PLATE1.csv PLATE2.csv ...  # convert 4x96-well plate annotations to a 384-well plate
```
Example input [input.csv]:

```csv
Plate,Well,siRNA,Drug,Concentration
Plate1,A1,PLK1,olaparib,0
Plate1,A2,siCON,olaparib,1
Plate1,A3,Allstar,olaparib,5
Plate1,A4,Mock,olaparib,10
Plate1,A5,BRCA1,olaparib,20
Plate1,A6,TP53,olaparib,50
Plate2,A1,PLK1,olaparib,0
Plate2,A2,siCON,olaparib,1
Plate2,A3,Allstar,olaparib,5
Plate2,A4,Mock,olaparib,10
Plate2,A5,ATR,olaparib,20
Plate2,A6,ATM,olaparib,50
Plate3,A1,PLK1,olaparib,0
Plate3,A2,siCON,olaparib,1
Plate3,A3,Allstar,olaparib,5
Plate3,A4,Mock,olaparib,10
Plate3,A5,PARP1,olaparib,20
Plate3,A6,ARID1A,olaparib,50
Plate4,A1,PLK1,olaparib,0
Plate4,A2,siCON,olaparib,1
Plate4,A3,Allstar,olaparib,5
Plate4,A4,Mock,olaparib,10
Plate4,A5,BRCA2,olaparib,20
Plate4,A6,PALB2,olaparib,50
```

```sh
bioplates
```


In a script:
```ruby
require 'bio-plates'
BioPlates.read("plate.csv")
#=> => {"Plate1"=>#<BioPlates::Plate:0x007fbc3b0cb260 @name="Plate1", @wells=[#<BioPlates::Plate::Well:0x007fbc3b0cb1e8 @row="A", @column="01", @annotation={:plate=>"Plate1", :drug=>"si1", :conc=>"5"}>, #<BioPlates::Plate::Well:0x007fbc3b0cabf8 @row="A", @column="02", @annotation={:plate=>"Plate1", :drug=>"si2", :conc=>"5"}>, #<BioPlates::Plate::Well:0x007fbc3b0ca540 @row="A", @column="03", @annotation={:plate=>"Plate1", :drug=>"si3", :conc=>"5"}>, #<BioPlates::Plate::Well:0x007fbc3b0c9c30 @row="A", @column="04", @annotation={:plate=>"Plate1", :drug=>"si4", :conc=>"5"}>...
## See specs for examples
```

Example CSV format. Must have a column headed Plate containing plate name, and either a well column Well (e.g. A01 or B4) or two further columns with Row and Column (A,3)
Any number of further columns can be specified for annotations
Multiple plates can be specified in the same file, these are read into a Hash keyed by plate name
```csv
  Plate,Well,Row,Column,siRNA,Conc
  Plate1,,A,1,si1,5
  Plate1,,A,2,si2,5
  Plate1,,A,3,si3,5
  Plate1,,A,4,si4,5
  Plate1,,A,5,si5,5
  Plate1,,A,6,si6,5
  Plate1,,A,7,si7,5
  Plate1,,A,8,si8,5
  Plate1,,A,9,si9,5
  Plate1,,A,10,si10,5
  Plate1,,A,11,si11,5
  Plate1,,A,12,si12,5
  Plate1,,B,1,si1,5
  Plate1,,B,1,si1,5
  Plate1,,B,1,si1,5
  Plate1,,B,1,si1,5
  ...
  Plate2,A01,,,si1,15
  Plate2,A02,,,si1,15
  Plate2,A03,,,si1,15
```

The API doc is online. For more code examples see the test files in
the source tree.

## Project home page

Information on the source tree, documentation, examples, issues and
how to contribute, see

  http://github.com/stveep/bioruby-plates

The BioRuby community is on IRC server: irc.freenode.org, channel: #bioruby.

## Cite

If you use this software, please cite one of

* [BioRuby: bioinformatics software for the Ruby programming language](http://dx.doi.org/10.1093/bioinformatics/btq475)
* [Biogem: an effective tool-based approach for scaling up open source software development in bioinformatics](http://dx.doi.org/10.1093/bioinformatics/bts080)

## Biogems.info

This Biogem is published at (http://biogems.info/index.html#bio-plates)

## Copyright

Copyright (c) 2015 stveep. See LICENSE.txt for further details.
