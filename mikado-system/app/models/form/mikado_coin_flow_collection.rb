class Form::MikadoCoinFlowCollection < Form::Base
  DEFAULT_ITEM_COUNT = 10
  attr_accessor :mikado_coin_flows

  def initialize(attributes = {})
    super attributes
    self.mikado_coin_flows = DEFAULT_ITEM_COUNT.times.map { MikadoCoinFlow.new } unless mikado_coin_flows.present?
  end

  def mikado_coin_flows_attributes=(attributes)
    self.mikado_coin_flows = attributes.map do |_, mikado_coin_flow_attributes|
      MikadoCoinFlow.new(mikado_coin_flow_attributes).tap {}
    end
  end

  def valid?
    valid_mikado_coin_flows = target_mikado_coin_flows.each(&:valid?)
    super && valid_mikado_coin_flows
  end

  def save!
    ActiveRecord::Base.transaction do
      MikadoCoinFlow.transaction { target_mikado_coin_flows.each(&:save!) }
    end
  end

  def target_mikado_coin_flows
    self.mikado_coin_flows.select { |v| v.register != "" }
  end
end
