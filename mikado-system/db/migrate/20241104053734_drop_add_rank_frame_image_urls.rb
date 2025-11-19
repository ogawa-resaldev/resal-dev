class DropAddRankFrameImageUrls < ActiveRecord::Migration[7.0]
  def up
    drop_table :add_rank_frame_image_urls
  end

  def down
    create_table :add_rank_frame_image_urls do |t|
      t.text :target_url, limit: 10000, :null => false, comment: '対象画像のurl'
      t.text :rank_frame_image_url, limit: 10000, :null => false, comment: 'ランキング枠画像のurl'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
