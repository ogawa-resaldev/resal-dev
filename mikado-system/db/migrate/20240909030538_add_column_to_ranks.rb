class AddColumnToRanks < ActiveRecord::Migration[7.0]
  def up
    add_column :ranks, :rank_frame_image_url, :text, :limit => 10000, :after => :reservation_price, comment: "ランキング枠の画像url"
  end

  def down
    remove_column :ranks, :rank_frame_image_url
  end
end
