module RanksHelper

  # 現在のランキングで対象となっている画像を更新。
  def self.update_target_image_urls_for_present_ranks
    require 'mechanize'
    require 'uri'
    require 'net/http'
    require 'json'

    # 画像urlのリスト
    image_url_list = []
    UserTherapistSetting.where.not(rank_id: nil).each do |user_therapist_setting|
      target_urls = []
      user_therapist_setting.user.user_therapists.each do |user_therapist|
        agent = Mechanize.new
        page_url = ""
        if ["横浜店","名古屋店"].include?(user_therapist.store.store_name) then
          # 横浜店、名古屋店は"blog/"を含まない。
          page_url = user_therapist.store.store_url.to_s + "cast/" + user_therapist.therapist_id.to_s + "/"
        else
          page_url = user_therapist.store.store_url.to_s + "blog/cast/" + user_therapist.therapist_id.to_s + "/"
        end
        uri = URI.parse(page_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme === "https"
        # codeが404の場合、対象から外す(非公開にしているパターンを考慮)。
        if http.get(uri).code != "404" then
          page = agent.get(page_url)
          page.search('#profile-thumbs').search('img').each do |ul|
            target_urls.push(ul.get_attribute('src').gsub!("-180x270.","."))
          end
        end
      end
      image_url_list.push({
        rank_frame_image_url:user_therapist_setting.rank.rank_frame_image_url,
        target_urls:target_urls
      })
    end

    # 更新。
    Net::HTTP.post_form(URI(ENV["UPDATE_RANK_FRAME_API"]), {token:ENV["UPDATE_RANK_FRAME_TOKEN"], image_url_list:image_url_list.to_json})
  end

  # ランキング更新とadd_rank_frame_image_urlsの更新。
  def self.reflectUserRank
    require 'uri'
    require 'net/http'
    require 'json'

    # 反映予定ランキングのリスト
    user_rank_list = []
    UserRank.where(reflection_date: nil).each do |user_rank|
      target_urls = []
      user_rank.user.user_therapists.each do |user_therapist|
        agent = Mechanize.new
        page_url = ""
        if ["横浜店","名古屋店"].include?(user_therapist.store.store_name) then
          # 横浜店、名古屋店は"blog/"を含まない。
          page_url = user_therapist.store.store_url.to_s + "cast/" + user_therapist.therapist_id.to_s + "/"
        else
          page_url = user_therapist.store.store_url.to_s + "blog/cast/" + user_therapist.therapist_id.to_s + "/"
        end
        page = agent.get(page_url)
        page.search('#profile-thumbs').search('img').each do |ul|
          target_urls.push(ul.get_attribute('src').gsub!("-180x270.","."))
        end
      end
      user_rank_list.push({
        user_id:user_rank.user.id,
        rank_id:user_rank.rank.id,
        rank_frame_image_url:user_rank.rank.rank_frame_image_url,
        target_urls:target_urls
      })
    end

    ActiveRecord::Base.transaction do
      # ユーザーのランクを削除。
      UserTherapistSetting.where.not(rank_id: nil).each do |user_therapist_setting|
        user_therapist_setting.update!(rank_id: nil)
      end
      # ユーザーランク反映日を削除。
      UserRankReflectionDate.all.delete_all
      # ユーザーランクの反映日を設定。
      UserRank.where(reflection_date: nil).each do |user_rank|
        user_rank.update!(reflection_date: Date.today)
      end

      # もろもろを更新。
      user_rank_list.each do |user_rank|
        UserTherapistSetting.find_by(user_id: user_rank[:user_id].to_i).update!(rank_id: user_rank[:rank_id].to_i)
      end
      Net::HTTP.post_form(URI(ENV["UPDATE_RANK_FRAME_API"]), {token:ENV["UPDATE_RANK_FRAME_TOKEN"], image_url_list:user_rank_list.to_json})
    end
  end
end
