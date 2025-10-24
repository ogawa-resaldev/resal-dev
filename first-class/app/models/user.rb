class User < ApplicationRecord
  acts_as_paranoid
  has_secure_password
  belongs_to :user_role
  has_one :user_therapist_setting
  has_many :user_therapists
  has_one :back_office_group
  accepts_nested_attributes_for :user_therapist_setting, allow_destroy: true
  accepts_nested_attributes_for :user_therapists, allow_destroy: true
  accepts_nested_attributes_for :back_office_group, allow_destroy: true
  before_create :encrypt_password_digest
  before_update :replace_autocomplete_tab
  validates :name, :login_id,
    presence: true
  validates :login_id,
    uniqueness: true
  validate :exist_user_therapist

  def encrypt_password_digest
    self.password_digest = BCrypt::Password.create(self.password_digest)
  end

  # tabがあるとautocompleteのjs実行時にエラーになるのでblankに変換。
  def replace_autocomplete_tab
    if self.user_therapist_setting.present? then
      if self.user_therapist_setting.auto_complete != nil then
        self.user_therapist_setting.auto_complete = self.user_therapist_setting.auto_complete.gsub(/\t/, ' ')
      end
    end
  end

  def assign_attributes_with_user_therapists(user_id, user_params)
    # パスワードは、入力の有無に関わらず、破棄(保存しているもので上書き)する。
    user_params["password_digest"] = User.find(user_id)[:password_digest]

    # user_therapists_attributesをループして、別でnewする。
    if user_params["user_therapists_attributes"].present?
      user_params["user_therapists_attributes"].each do |index, user_therapists_attribute|
        if !user_therapists_attribute["id"].present? then
          # idのないattributeは新規なので、newしてself.user_therapists.targetにpushし、user_paramsからは削除。
          # (notification_group_idは、idない場合に非表示にするように_user_therapist_fieldsで設定しているので、あまり意味ない。)
          # こうやらないで、そのままself.assign_attributesを使うとDecryptionのErrorが発生して進まない。
          self.user_therapists.target.push(UserTherapist.new(
            user_id: user_id,
            store_id: user_therapists_attribute["store_id"],
            therapist_id: user_therapists_attribute["therapist_id"],
            notification_group_id: user_therapists_attribute["notification_group_id"]
          ))
          user_params["user_therapists_attributes"].delete(index)
        end
      end
    end
    self.assign_attributes(user_params)
  end

  scope :all_by_user, -> (user_id){
    user_role_id = User.find(user_id)[:user_role_id]
    case user_role_id
    # セラピスト
    when 1 then
      # findにすると、そのあとwhereを使用できなくなる。
      User.where(id: user_id)
    # 管理者
    when 2 then
      User.where(active_flag: 1)
    # 内勤
    when 3 then
      store_group_id = BackOfficeGroup.find_by(user_id: user_id)[:store_group_id]
      user_ids = UserTherapist.where(store_id: Store.where(store_group_id: store_group_id)).pluck(:user_id)

      User.joins("left outer join back_office_groups on users.id = back_office_groups.user_id")
      .where(id: User.joins("left outer join (select * from user_therapists where deleted_at is null) as user_therapists on users.id = user_therapists.user_id")
      .where(active_flag: 1)
      .where(user_role_id: 1)
      .where(user_therapists: {id: nil}).pluck(:id)) # 店舗紐付けなし
      .or(User.where(id: user_ids)) # 店舗グループに紐付けされたセラピスト
      .or(User.where(back_office_groups: {store_group_id: store_group_id})) # 店舗グループ内の内勤ユーザー
    end
  }

  private def exist_user_therapist
    require 'uri'
    require 'net/http'
    require 'json'
    # すでに他のユーザーに設定されたユーザーセラピストだったら、エラー判定。
    self.user_therapists.each do |user_therapist|
      userTherapist = UserTherapist.find_by(store_id: user_therapist[:store_id], therapist_id: user_therapist[:therapist_id])
      if userTherapist.present? then
        if self.read_attribute(:id) != userTherapist.user.id then
          uri = URI.parse(userTherapist.store.store_url + 'wp-json/wp/v2/casts/' + user_therapist[:therapist_id].to_s)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = uri.scheme === "https"
          response = JSON.load(http.get(uri).body)
          if response.key?("title") then
            self.errors.add(:base, userTherapist.store.store_name + 'の' + response["title"]["rendered"] + 'さんは、すでに別のユーザーに設定されています。')
          else
            self.errors.add(:base, '設定しようとした店舗×セラピストは、すでに別のユーザーに設定されています。')
          end
        end
      end
    end
  end
end
