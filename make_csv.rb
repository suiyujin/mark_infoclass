require 'csv'

class MakeCsv
  def initialize(file_name)
    @file_name = file_name
    header = ['user_id', 'user_name', 2, 7, 8, 14, 17, 19, 'feedback_19', 22]
    CSV.open("result/#{file_name}", 'w') { |csv_file| csv_file << header }
  end

  def write(matrix)
    CSV.open("result/#{@file_name}", 'a') do |csv_file|
      matrix.each { |row| csv_file << row }
    end
    p 'msg: csv file writed.'
  end
end
