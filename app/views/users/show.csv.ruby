require 'csv'

CSV.generate do |csv|
  column_names = %w(日付 曜日 出勤時間 退勤時間)
  csv << column_names
  @dates.each do |day|
    column_values = [

      l(day.worked_on, format: :short1),

      $days_of_the_week[day.worked_on.wday],

      if day.change_started.present? && day.attendance_approval == "承認"
        day.change_started.strftime("%R")
      elsif day.started_at.present? && day.attendance_approval != "承認"
        day.started_at.strftime("%R")
      end,

      if day.change_finished.present? && day.attendance_approval == "承認"
        day.change_finished.strftime("%R")
      elsif day.finished_at.present? && day.attendance_approval != "承認"
        day.finished_at.strftime("%R")
      end

    ]
    csv << column_values
  end
end