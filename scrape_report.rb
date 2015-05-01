require 'mechanize'
require 'dotenv'
Dotenv.load

class ScrapeReport

  AFTER_NEXT_VALUE = 2
  HEADER_NUM = 1
  STUDENTS_NUM = 89

  GOOD_SCORE = 1.0
  POOR_SCORE = 0.5
  BAD_SCORE = 0.0

  attr_reader :evaluations

  def initialize(report_num)
    @report_num = report_num
    @agent = Mechanize.new
    @agent.request_headers = { 'accept-language' => 'en' }
    @evaluations = Array.new(STUDENTS_NUM)
  end

  def login(url)
    top_page = @agent.get(url)
    login_page = top_page.link_with(:text => 'Log in').click

    login_page.form do |form|
      form.username = ENV['USERNAME']
      form.password = ENV['PASSWORD']
    end.submit
  end

  def move_to_report_page(home_page)
    my_course = home_page.link_with(text: 'マイコース').click
    my_course.link_with(text: '課題').click

    reports_links = my_course.search('div#region_12_assign_inner').children.children.children

    link_index = reports_links.find_index do |children|
      children.text == "【確認】 練習#{@report_num}の結果を提出する"
    end
    raise ArgumentError, "wrong report number (#{@report_num})." if link_index.nil?

    select_report_page(my_course, find_report_url(reports_links, link_index + AFTER_NEXT_VALUE))
  end

  def scrape(report_page)
    # 姓の順に並べ替える
    report_page_sorted = report_page.link_with(href: /lastname/).click

    # 提出ファイルの列番号を調べる
    header = report_page_sorted.search('th')
    check_index = header.find_index { |children| children.text == 'ファイル提出' }

    students = report_page_sorted.search('tr:not(.emptyrow)').drop(HEADER_NUM)
    students.each_with_index do |student, i|
      unless @report_num == 19
        @evaluations[i] = submit_file?(student, check_index, '.docx') ? GOOD_SCORE : BAD_SCORE
      else
        @evaluations[i] = calc_score_of_report_19(student, check_index)
      end
    end
  end

  def calc_score_of_report_19(student, check_index)
    case true
    when submit_file?(student, check_index, '.pdf') && submit_file?(student, check_index, '.docx')
      GOOD_SCORE
    when submit_file?(student, check_index, '.pdf') || submit_file?(student, check_index, '.docx')
      POOR_SCORE
    else
      BAD_SCORE
    end
  end

  def find_report_url(reports_links, index)
    reports_links[index].attributes['href'].value
  end

  def select_report_page(my_course, report_url)
    my_course.link_with(href: report_url).click
  end

  def submit_file?(student, check_index, extname)
    student.children[check_index].text.include?(extname)
  end
end
