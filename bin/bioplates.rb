#!/usr/bin/env ruby
require 'bio-plates'
require 'thor'

class BioPlatesCLI < Thor
  desc "quadrants PLATE1.csv PLATE2.csv ...", "convert 4x96-well plate annotations to a 384-well plate"
  def quadrants(*plates)
    # read files and merge
    plate_array = []
    plates.each do |plate|
      # TODO: check/warn if any plate names are the same
      BioPlates.read(plate).each{|k,v| plate_array << v}
    end
    BioPlates.quadrants(plate_array).dump
  end


end

BioPlatesCLI.start(ARGV)
