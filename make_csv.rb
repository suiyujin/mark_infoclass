require 'csv'

class MakeCsv
  def initialize(file_name)
    @file_name = file_name
  end

  def write(matrix)
    CSV.open("result/#{@file_name}", 'w') do |csv_file|
      matrix.each { |row| csv_file << row }
    end
    p 'msg: csv file writed.'
  end
end
