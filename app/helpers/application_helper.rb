module ApplicationHelper
  # ページごとに応じたタイトルを返す。
  def full_title(page_title = '')
    base_title = "勤怠システム"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end
end

# このfull_titleヘルパーメソッドは、引数をpage_titleとしています。
# まずbase_titleに基本のタイトルである"勤怠システムを代入"
# その後の条件式として、
# もし引数page_titleが空だったら、base_title(勤怠システム)を出力
# 値が何か代入されていたら、page_title（代入値） + " | " + base_title（勤怠システム）を出力
# 結果、「Top ｜ 勤怠システム」　のようになります。