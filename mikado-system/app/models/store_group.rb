class StoreGroup < ApplicationRecord
  encrypts :mail_signature
  encrypts :mail_transfer_bank
  encrypts :mail_credit_1
  encrypts :mail_credit_2
  encrypts :line_client_id
  encrypts :line_client_secret
  encrypts :line_default_target_id
  has_many :stores
  acts_as_paranoid
  validates :name, :credit_fee_percentage, :mail_api, :mail_name, :mail_signature, :mail_transfer_bank, :mail_credit_1, :mail_credit_2, :line_client_id, :line_client_secret, :line_default_target_id,
    presence: true
  validates :name,
    uniqueness: true

  scope :all_by_user, -> (user_id){
    user_role_id = User.find(user_id)[:user_role_id]
    case user_role_id
    # セラピスト
    when 1 then
      storeIdList = UserTherapist.where(user_id: user_id).pluck(:store_id)
      StoreGroup.where(id: Store.where(id: storeIdList).pluck(:store_group_id))
    # 管理者
    when 2 then
      StoreGroup.all
    # 内勤
    when 3 then
      StoreGroup.where(id: BackOfficeGroup.find_by(user_id:user_id)[:store_group_id])
    end
  }
end
