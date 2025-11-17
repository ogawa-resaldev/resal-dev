class CreateCourseDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :course_details do |t|
      t.integer :course_id, :null => false, comment: 'コースID'
      t.string :name, :null => false, comment: '表示名'
      t.string :abbreviation, :null => false, comment: '略称'
      t.integer :duration, :null => false, comment: '所要時間(分)'
      t.integer :price, :null => false, comment: '料金(円)'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
