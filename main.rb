require 'scrape_report.rb'
require 'make_csv.rb'

class Main

  STUDENTS_NUM = 89

  def initialize
    @evaluations_matrix = Array.new(STUDENTS_NUM).map { Array.new }
  end

  def run(report_num)
    moodle = ScrapeReport.new(report_num)

    home_page = moodle.login('http://darwin.lila.cs.tsukuba.ac.jp/moodle/')
    report_page = moodle.move_to_report_page(home_page)
    moodle.scrape(report_page)

    add_matrix_f(moodle.evaluations)
    add_matrix(moodle.feedback) if report_num == 19
  end

  def export_csv(file_name)
    csv = MakeCsv.new(file_name)
    csv.write(@evaluations_matrix)
  end

  def add_matrix(data)
    @evaluations_matrix.each_with_index do |evaluations_by_student, student_num|
      evaluations_by_student << data[student_num]
    end
  end

  def add_matrix_f(data)
    add_matrix(data.map(&:to_f))
  end

end
