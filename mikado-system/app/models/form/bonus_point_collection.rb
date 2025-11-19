class Form::BonusPointCollection < Form::Base
  DEFAULT_ITEM_COUNT = 10
  attr_accessor :bonus_points

  def initialize(attributes = {})
    super attributes
    self.bonus_points = DEFAULT_ITEM_COUNT.times.map { BonusPoint.new } unless bonus_points.present?
  end

  def bonus_points_attributes=(attributes)
    self.bonus_points = attributes.map do |_, bonus_point_attributes|
      BonusPoint.new(bonus_point_attributes).tap {}
    end
  end

  def valid?
    valid_bonus_points = target_bonus_points.each(&:valid?)
    super && valid_bonus_points
  end

  def save!
    ActiveRecord::Base.transaction do
      BonusPoint.transaction { target_bonus_points.each(&:save!) }
    end
  end

  def target_bonus_points
    self.bonus_points.select { |v| v.register != "" }
  end
end
