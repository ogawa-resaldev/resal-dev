class Review < ApplicationRecord
  encrypts :name, :mail_address
  acts_as_paranoid
  belongs_to :user
  validates :reservation_name, :reservation_mail_address, :post_date, :content,
    presence: true

  def abridged_content
    if !(self.read_attribute(:content).length <= 10) then
      return self.read_attribute(:content)[0, 10] + "...."
    else
      return self.read_attribute(:content)
    end
  end

  def formatted_review
    nickname = "匿名希望"
    if self.read_attribute(:nickname).present? then
      nickname = self.read_attribute(:nickname) + "様"
    end
    content = self.read_attribute(:content)
    content = content.gsub(/\R/, "\n")
    while content.start_with?("\n") do
      content = content[1..-1]
    end
    while content.end_with?("\n") do
      content = content[0..-2]
    end
    return "<strong>" + nickname + "　" + self.read_attribute(:age) + "(" + self.read_attribute(:post_date).strftime('%Y/%m/%d') + ")</strong>\n\n" + content
  end
end
