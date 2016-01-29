class BioPlates
  require 'csv'
  def self.read(file)
    plates = Hash.new{|h,k| h[k] = BioPlates::Plate.new(k)}
    csv = CSV.read(File.open(file), headers: true, header_converters: :symbol)
    unless csv.headers.include? :well || ((csv.headers.include? :row) && (csv.headers.include? :column))
      raise "Column headers must include either Well, or Row and Column"
    end
    csv.each do |row|
      plates[row[:plate]].wells << BioPlates::Plate::Well.new(row)
    end
    plates.map{|k,v| v.add_leading_zeroes!}
    # Return a hash of Plate Objects for all the plates in the CSV
    #plates.each.map!{|k,v| v.name = k}
    plates
  end

  # form quadrants from four plate Objects
  def self.quadrants(plates,newname="QuadrantPlate")
    if plates.is_a? Hash
      plates = plates.sort.to_h.values
    end
    unless plates.length == 4
      warn "Number of plates supplied should be four; truncating/reusing"
      if plates.length > 4
        plates = plates[0..3]
      elsif plates.length < 4
        i = 0
        until plates.length == 4 do
          duplicate = plates[i].dup
          duplicate.wells = duplicate.wells.map(&:dup)
          plates << duplicate
	  # Keep incrementing as long as there are still supplied plates, else reset
          i < plates.length ? i += 1 : i = 0
        end
      end
    end
    newplate = BioPlates::Plate.new(newname)
    plates.each.with_index do |plateobj, plateno|
      plateno = plateno + 1
      modplate = plateobj.dup
      modplate.wells.map!{|x| x.quadrantize!(plateno)}
      modplate.add_leading_zeroes!
      modplate.wells.map(&:index!)
      newplate.wells = newplate.wells + modplate.wells
    end
    newplate.wells = newplate.wells.sort_by{|w| w.well}
    newplate
  end

end




class BioPlates::Plate
  attr_accessor :wells, :name, :rows, :columns

  def initialize(name="")
    @name = name
    @wells = []
  end

  def each
    @wells.each
  end

  def rows
    @rows = Hash.new{|h,k| h[k] = []}
    @wells.each{|well| @rows[well.row] << well}
    @rows
  end

  def columns
    @columns = Hash.new{|h,k| h[k] = []}
    @wells.each{|well| @columns[well.column] << well}
    @columns
  end

  # Add leading zeroes to column strings
  def add_leading_zeroes!
    max = self.wells.dup.sort_by!{|x| x.column.to_s.length}.pop.column.to_s.length
    self.wells.map!{|x| y = ""; (max - x.column.to_s.length).times{y << "0"} ; x.column = y + x.column.to_s; x }
    self
  end

  def dump(file="output.csv",head=true,format="csv")
    #Column titles required:
    columns = Hash.new{|h,k| h[k] = 1}
    self.wells.each do |well|
      well.annotation.each{|k,v| columns[k] += 1}
    end
    columns.delete(:plate) # Remove original plate annotation
    CSV.open(file,"wb") do |csv|
      if head
        csv << ["Plate","Row","Column"] + columns.keys
        head = false
      end
      self.wells.each do |well|
        line = [self.name,well.row,well.column]
        columns.keys.each do |col_title|
          if well.annotation.keys.include?(col_title)
            line << well.annotation[col_title]
          else
	    # Any wells without value for an annotation get a zero
            line << 0
          end
        end
      csv << line
      end
    end

  end

end

class BioPlates::Plate::Well
  attr_accessor :row, :column, :annotation, :well
  @@regexp = /(?<row>[A-Za-z]+)(?<column>\d+)/
  # Better not to hard code these...
  @@nrow = 8
  @@ncol = 12
  def initialize(hash)

    if hash[:row] && hash[:column]
      @row = hash[:row]
      @column = hash[:column].to_s
    else
      # Split the well annotation if row & col not given separately
      m = hash[:well].match(@@regexp)
      @well = hash[:well]
      @row = m[:row]
      @column = m[:column]
    end
    # NB annotation includes the original well annotation
    @annotation = hash.delete_if{|k,f| [:row, :column, :well].include? k}.to_h
  end

  def index!
    @well = @row.upcase.to_s + @column
  end

  def quadrantize!(plate)
    self.index! unless @well
    @annotation[:original_well] = @well
    @annotation[:original_plate] = @annotation[:plate]
    @annotation.delete(:plate) # Remove so no conflict with new plate
    (plate == 2 || plate == 4) ? inc = 1 : inc = 0
    (plate == 3 || plate == 4) ? rowinc = 1 : rowinc = 0
    @column = (@column.to_i + [*0..@@ncol][@column.to_i-1]+inc).to_s
    @row = (@row.ord + [*0..@@nrow][@row.upcase.ord-65]+rowinc).chr # 65 = ASCII "A"
    self
  end

  def quadrantize(plate)
    dup = self.dup
    dup.quadrantize!(plate)
  end
end
