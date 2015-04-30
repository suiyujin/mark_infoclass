require 'scrape_report.rb'

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

    add_matrix(moodle.evaluations)

    binding.pry
  end

  def add_matrix(evaluations)
    @evaluations_matrix.each_with_index do |evaluations_by_student, student_num|
      evaluations_by_student << evaluations[student_num]
      evaluations_by_student << ''
    end
  end
end
