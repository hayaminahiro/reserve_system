class User < ApplicationRecord
  # Userモデルから見たAttendanceモデルは1対多
  # dependent: :destroy → Userを削除すると関連するAttendanceデータも同時に削除
  has_many :attendances, dependent: :destroy
  attr_accessor :remember_token
  
  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
              format: { with: VALID_EMAIL_REGEX },
              uniqueness: { case_sensitive: false }
  validates :affiliation, length: { in: 3.. 50 }, allow_blank: true
  
  # 指定勤務時間と基本勤務時間がない場合のエラー処理
  validates :basic_work_time, presence: true
  validates :work_time, presence: true
  validates :designated_work_start_time, presence: true
  validates :designated_work_end_time, presence: true
  
  # 指定勤務開始時間と指定勤務終了時間がない場合のエラー処理
  validates :designated_work_start_time, presence: true
  validates :designated_work_end_time, presence: true
  
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # 永続セッションの為にユーザーをデータベースに記憶
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  # 検索機能
  def self.search(search) #ここでのself.はUser.を意味する
    if search
      where(['name LIKE ?', "%#{search}%"]) #検索とnameの部分一致を表示。User.は省略
    else
      all #全て表示。User.は省略
    end
  end
  
  # CSV機能
  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      # IDが見つかれば、レコードを呼び出し、見つかれなければ、新しく作成
      user = find_by(name: row["name"]) || new
      # CSVからデータを取得し、設定する
      user.attributes = row.to_hash.slice(*updatable_attributes)
      # 保存する
      user.save
    end
  end

  # 更新を許可するカラムを定義
  def self.updatable_attributes
    ["name", "email", "affiliation", "employee_number", "uid", "basic_work_time", 
    "designated_work_start_time", "designated_work_end_time", "admin", "password"]
  end
end

# モデルとは何か説明・・・まずMVCに分類し簡単に説明
# ・モデル（Model）：表示や入力に関連しない処理
# ・ビュー（View）：表示や入力に関する処理
# ・コントローラ（Controller）：ビューとモデルの橋渡し役

# モデルとはどんなデータ構成をしているか表したもの
# 例えばUserモデル：
# カラムにはnameとemailがあり、それぞれのデータ型はstringである・・・というような。
#
# railsで情報を保存する場合、リレーショナルデータベースを使用しますが、
# これはデータが行で構成されるテーブル構造になっています。
#
# nameとemailをカラムに持つユーザーをデータベースに保存する場合、usersテーブルが必要
# 各行に１ユーザーを保存します。



