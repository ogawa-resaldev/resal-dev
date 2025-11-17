class CreateRanks < ActiveRecord::Migration[7.0]
  def change
    create_table :ranks do |t|
      t.string :rank, :null => false, comment: 'ランク'
      t.string :name, :null => false, comment: 'ランク名'
      t.integer :reservation_price, :null => false, comment: '指名料'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
