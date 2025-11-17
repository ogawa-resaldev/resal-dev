class UserRankReflectionDate < ApplicationRecord
  validates :reflection_date,
    presence: true

  # 次の反映日もしくはコメントをレコードの状況を加味して返却
  def next_reflection_date
    case UserRankReflectionDate.all.count
    when 0 then
      return ""
    when 1 then
      return UserRankReflectionDate.first.reflection_date.strftime('%Y/%m/%d')
    else
      return "異常な反映日が設定されているので、設定し直してください。"
    end
  end
end
