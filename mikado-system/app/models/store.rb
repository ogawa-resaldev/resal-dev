class Store < ApplicationRecord
  acts_as_paranoid
  belongs_to :store_group
  before_create :add_slash
  before_update :add_slash
  has_many :pass_classifications
  validates :store_name, :store_url, :store_group_id, :active_flag,
    presence: true
  validates :store_name, :store_url,
    uniqueness: true

  def add_slash
    if self.store_url[-1] != "/"
      self.store_url = self.store_url + "/"
    end
  end

  scope :all_by_user, -> (user_id){
    user_role_id = User.find(user_id)[:user_role_id]
    case user_role_id
    # セラピスト
    when 1 then
      store_id_list = UserTherapist.where(user_id: user_id).pluck(:store_id)
      Store.where(id: store_id_list)
    # 管理者
    when 2 then
      Store.all
    # 内勤
    when 3 then
      Store.where(store_group_id: BackOfficeGroup.find_by(user_id:user_id)[:store_group_id])
    end
  }
end
