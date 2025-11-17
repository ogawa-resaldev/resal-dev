class CreateApplicantDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :applicant_details do |t|
      t.integer :applicant_id, :null => false, comment: '応募者ID'
      t.date :application_date, :null => false, comment: '応募日'
      t.integer :preferred_store_id, :null => false, comment: '希望の所属店舗ID'
      t.string :preferred_store_text, comment: '希望の所属店舗(text)'
      t.string :name, :null => false, comment: 'お名前'
      t.string :tel, :null => false, comment: '電話番号'
      t.string :mail_address, :null => false, comment: 'メールアドレス'
      t.integer :age, :null => false, comment: '年齢'
      t.integer :height, :null => false, comment: '身長'
      t.integer :weight, :null => false, comment: '体重'
      t.string :nearest_station, :null => false, comment: '最寄駅'
      t.string :education, :null => false, comment: '学歴'
      t.string :occupation, :null => false, comment: '職業'
      t.string :work_frequency, :null => false, comment: '出勤頻度'
      t.string :experience_count, :null => false, comment: '経験人数'
      t.string :smoking, :null => false, comment: '喫煙'
      t.string :has_tattoo, :null => false, comment: 'タトゥーの有無'
      t.string :therapist_experience, :null => false, comment: 'セラピスト経験・期間'
      t.string :mosaic, :null => false, comment: 'モザイク'
      t.string :how_to_know, :null => false, comment: '当店をどこで知りましたか？'
      t.text :motivation, :null => false, comment: '志望動機'
      t.text :self_pr, :null => false, comment: '自己アピール'
      t.text :other_questions, comment: 'その他、ご質問等'
      t.string :image_one_path, comment: '写真1path'
      t.string :image_two_path, comment: '写真2path'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
