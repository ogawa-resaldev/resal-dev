class PassClassificationFee < ApplicationRecord
  acts_as_paranoid
  belongs_to :pass_classification
  validates :fee_name, :amount,
    presence: true

  # 注釈がnilの場合、空文字にする。
  def annotation
    super.presence || ""
  end
end
