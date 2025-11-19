class CreateCourses < ActiveRecord::Migration[7.0]
  def change
    create_table :courses do |t|
      t.string :name, :null => false, comment: 'コース名'
      t.string :course_key, :null => false, comment: 'コースkey'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
