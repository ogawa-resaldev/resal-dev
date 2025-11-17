class ChangeApplicantStoreIdColumnToApplicants < ActiveRecord::Migration[7.0]
  def up
    change_column_comment(:applicants, :applicant_store_id, '求人応募店舗ID')
  end

  def down
    change_column_comment(:applicants, :applicant_store_id, '求人応募店舗ID。システムで登録した場合はnullにする。')
  end
end
