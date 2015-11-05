class BioPlates
  require 'csv'
  def self.read(file)
    plates = Hash.new{|h,k| h[k] = BioPlates::Plate.new}
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
  def self.quadrants(plates)
    if plates.is_a? Hash
      plates = plates.values
    end
    unless plates.length == 4
      warn "Number of plates supplied should be four; truncating/reusing"
      if plates.length > 4
        plates = plates[0..3]
      elsif plates.length < 4
        i = 0
        until plates.length == 4 do
          duplicate = plates[i].dup
          duplicate.wells.map!(&:dup)
          plates << duplicate
          i += 1
        end
      end
    end
    puts plates
    newplate = BioPlates::Plate.new
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

  def initialize
    @wells = []
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
    max = self.wells.dup.sort_by!{|x| x.column.length}.pop.column.length
    self.wells.map!{|x| y = ""; (max - x.column.length).times{y << "0"} ; x.column = y + x.column; x }
    self
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
    @annotation = hash.delete_if{|k,f| [:row, :column, :plate, :well].include? k}
  end

  def index!
    @well = @row.upcase.to_s + @column
  end

  def quadrantize!(plate)
    (plate == 2 || plate == 4) ? inc = 1 : inc = 0
    (plate == 3 || plate == 4) ? rowinc = 1 : rowinc = 0
    puts self.inspect
    @column = (@column.to_i + [*0..@@ncol][@column.to_i-1]+inc).to_s
    @row = (@row.ord + [*0..@@nrow][@row.upcase.ord-65]+rowinc).chr # 65 = ASCII "A"
    self
  end

  def quadrantize(plate)
    dup = self.dup
    dup.quadrantize!(plate)
  end
end
