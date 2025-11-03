class UserTherapist < ApplicationRecord
  encrypts :notification_group_id
  acts_as_paranoid
  belongs_to :user
  belongs_to :store
  validates :therapist_id,
    presence: true

  def store_name
    if Store.find_by(id: self.read_attribute(:store_id)).blank? then
      return ""
    else
      return Store.find_by(id: store_id)[:store_name]
    end
  end

  def therapist_name
    require 'uri'
    require 'net/http'
    require 'json'
    if !self.read_attribute(:store_id).blank? then
      uri = URI.parse(Store.find(self.read_attribute(:store_id)).store_url + 'wp-json/wp/v2/users/' + self.read_attribute(:therapist_id).to_s)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      response = JSON.load(http.get(uri).body)
      if response.key?("name") then
        return response["name"]
      end
    end
    return ""
  end

  def edit_flag(user_id)
    user_role_id = User.find(user_id)[:user_role_id]
    case user_role_id
    # 管理者
    when 2 then
      true
    # 内勤
    when 3 then
      # idがnilのものは追加用だと思われるので強制的にtrueにする。
      if !self.read_attribute(:id).blank? then
        store_group_id = BackOfficeGroup.find_by(user_id: user_id)[:store_group_id]
        store_id_list = Store.where(store_group_id: store_group_id).pluck(:id)
        return store_id_list.include?(self.read_attribute(:store_id))
      else
        return true
      end
    else
      return false
    end
  end
end
