# Annnotation of plates given ranges
# which I was too lazy to rewrite in Ruby.
class BioPlates::Annotator
  require 'rinruby'

  class << self
    attr_accessor :annotate_lib
  end
  @annotate_lib = File.join(File.dirname(__FILE__),"plate_annotate.r")

  def self.read (file)
    R.annofile = file
    R.eval "annofile = read.table(annofile,head=T)"
  end

  def self.annotate (file,outfile)
    BioPlates::Annotator.read(file)
    R.eval "source('#{@annotate_lib}')"
    R.eval "anno_df <- annotate_plate(annofile)"
    R.outfile = outfile
    R.eval "write.csv(anno_df,outfile,quote=F,row.names=F)"
  end

end
