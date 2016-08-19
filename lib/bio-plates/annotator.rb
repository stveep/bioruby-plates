# Annnotation of plates given ranges
# which I was too lazy to rewrite in Ruby.
class BioPlates::Annotator
  require 'rinruby'

  class << self
    attr_accessor :annotate_lib, :sep
  end
  @sep = "\t"
  @annotate_lib = File.join(File.dirname(__FILE__),"plate_annotate.r")

  def self.read (file)
    R.annofile = file
    R.field_sep = BioPlates::Annotator.sep
    if file.match /\.xls[xm]?\z/
      R.eval "if(require('readxl') == FALSE) { install.packages('readxl', repos='http://cran.us.r-project.org', dependencies=TRUE) }"
      R.eval "annofile = read_excel(annofile,col_names=TRUE)" 
    else
      R.eval "annofile = read.table(annofile,head=T,sep=field_sep)"
    end
  end

  def self.annotate (file,outfile)
    BioPlates::Annotator.read(file)
    R.eval "source('#{@annotate_lib}')"
    R.eval "anno_df <- annotate_plate(annofile)"
    R.outfile = outfile
    R.eval "write.csv(anno_df,outfile,quote=F,row.names=F)"
  end

end
