class AddColumnToCourses < ActiveRecord::Migration[7.0]
  def change
    add_column :courses, :sort_order, :integer, :null => false, :default => 100, :after => :id, comment: "ソート順"
  end
end
