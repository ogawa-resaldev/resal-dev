class PassClassification < ApplicationRecord
  acts_as_paranoid
  has_many :pass_classification_fees
  accepts_nested_attributes_for :pass_classification_fees, allow_destroy: true
  belongs_to :store_group
  validates :classification_name, uniqueness: { scope: :store_group_id }
  validates :classification_name, presence: true

  scope :all_by_store, -> (store_id){
    PassClassification.where(store_group_id: Store.find(store_id).store_group.id)
  }

  scope :all_by_user, -> (user_id){
    user_role_id = User.find(user_id)[:user_role_id]
    case user_role_id
    # 管理者
    when 2 then
      PassClassification.all
    # 内勤
    when 3 then
      store_group_id = BackOfficeGroup.find_by(user_id: user_id)[:store_group_id]
      PassClassification.where(store_group_id: store_group_id)
    end
  }
end
