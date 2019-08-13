module UsersHelper
  # 基本時間・指定勤務時間などをフォーマット化
  def format_basic_info(datetime)
    format("%.2f", ((datetime.hour * 60) + datetime.min) / 60.0)
  end
  
#   (例) 18:30 => 18.5
# “%.2f”, ((datetime.hour * 60) + datetime.min)/60.0)

# a = 18(datetime.hour) * 60 == 1080
# b = 30(datetime.min)
# c = a + b ==  1110 / 60.0
# c = 18.5

# %.2f => 「小数点2までを表示する」という意味(18.25の場合もあるため)


# 今回の例としてあげたパターンだと、
# ・「全体をまず分単位で統一する」　18時*60 == 1080分
# ・1080分 + 30分 = 1110分
# ・1110分を時間単位に戻す。
# ・1110分/60.0(小数点0をつけないと0.5が表示されない。切り捨て) = 18.5

end
