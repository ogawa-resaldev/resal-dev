class CreateReservationCourses < ActiveRecord::Migration[7.0]
  def change
    create_table :reservation_courses do |t|
      t.integer :reservation_id, :null => false, comment: '予約ID'
      t.string :course, :null => false, comment: 'コース'
      t.string :course_detail, :null => false, comment: 'コース詳細'
      t.integer :duration, :null => false, comment: '所要時間(分)'
      t.integer :amount, :null => false, comment: '金額(円)'
      t.integer :back_therapist_amount, :null => false, comment: 'セラピストバック金額(円)'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
