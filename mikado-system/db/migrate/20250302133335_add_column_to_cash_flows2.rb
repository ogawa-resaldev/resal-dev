class AddColumnToCashFlows2 < ActiveRecord::Migration[7.0]
  def up
    add_column :cash_flows, :cash_flow_period, :date, :default => nil, :after => :occurrence_date, comment: "締め切り日"
  end

  def down
    remove_column :cash_flows, :cash_flow_period
  end
end
