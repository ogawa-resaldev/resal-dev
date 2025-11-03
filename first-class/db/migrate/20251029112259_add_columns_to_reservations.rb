class AddColumnsToReservations < ActiveRecord::Migration[7.0]
  def up
    # remove_column :reservations, :tel
    # remove_column :reservations, :mail_address
    # remove_column :reservations, :address
    add_column :reservations, :contact_method, :string, :default => nil, :after => :name, comment: "連絡手段"
    add_column :reservations, :meeting_count, :integer, :null => false, :default => 0, :after => :contact_method, comment: "対面回数"
    add_column :reservations, :call_count, :integer, :null => false, :default => 0, :after => :meeting_count, comment: "通話件数"
  end

  def down
    remove_column :reservations, :contact_method
    remove_column :reservations, :meeting_count
    remove_column :reservations, :call_count
    # add_column :reservations, :tel, :string, :null => false, :after => :name, comment: "予約電話番号"
    # add_column :reservations, :mail_address, :string, :null => false, :after => :tel, comment: "予約メールアドレス"
    # add_column :reservations, :address, :string, :after => :place, comment: "住所"
  end
end
