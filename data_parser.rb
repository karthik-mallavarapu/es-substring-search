# Instantiate this class for parsing data and header fields. 
class DataParser
  def initialize(filepath)
    @filepath = filepath
    @csv = CSV.read(filepath, headers: true, converters: :all)
  end

  # Returns header fields as an array.
  def header_fields
    @csv.headers
  end

  # Expects a block. Iterates over all the data rows and calls the block for
  # each row.
  def each_row(&block)
    @csv.each do |row|
      yield(row) if block_given?
    end
  end
end
