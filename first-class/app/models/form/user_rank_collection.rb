class Form::UserRankCollection < Form::Base
  DEFAULT_ITEM_COUNT = 25
  attr_accessor :user_ranks

  def initialize(attributes = {})
    super attributes
    self.user_ranks = DEFAULT_ITEM_COUNT.times.map { UserRank.new } unless user_ranks.present?
  end

  def user_ranks_attributes=(attributes)
    self.user_ranks = attributes.map do |_, user_rank_attributes|
      UserRank.new(user_rank_attributes).tap {}
    end
  end

  def valid?
    valid_user_ranks = target_user_ranks.all?(&:valid?)
    super && valid_user_ranks
  end

  def save!
    ActiveRecord::Base.transaction do
      UserRank.transaction { target_user_ranks.each(&:save!) }
    end
  end

  def target_user_ranks
    self.user_ranks.select { |v| v.register_user != "" }
  end
end
