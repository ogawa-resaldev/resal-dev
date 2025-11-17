class ChangeColumnsToApplicantDetails < ActiveRecord::Migration[7.0]
  def up
    change_column :applicant_details, :motivation, :text, :null => true
    change_column :applicant_details, :self_pr, :text, :null => true
  end

  def down
    change_column :applicant_details, :motivation, :text, :null => false
    change_column :applicant_details, :self_pr, :text, :null => false
  end
end
