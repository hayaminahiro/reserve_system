require 'csv'

#CSV.generate do |csv|
#  column_names = %w(日付 出勤時間 退勤時間)
#  csv << column_names
#  @dates.each do |day|
#    column_values = [
#        day.worked_on.to_s(:date),
#        if day.started_at.present?
#          day.started_at.strftime("%R")
#        end,
#        if day.finished_at.present?
#          day.finished_at.strftime("%R")
#        end
#    ]
#    csv << column_values
#  end
#end