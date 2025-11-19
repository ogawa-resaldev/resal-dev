class CreatePassClassificationFees < ActiveRecord::Migration[7.0]
  def change
    create_table :pass_classification_fees do |t|
      t.integer :pass_classification_id, :null => false, comment: '通過区分ID'
      t.string :fee_name, :null => false, comment: '費用名'
      t.integer :amount, :null => false, comment: '料金'
      t.string :annotation, comment: '注釈'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
