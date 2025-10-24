module ReviewsHelper

  # word pressに持っているsystem_reviewsテーブルをAPI経由で更新。
  def self.update_wp_reviews
    require 'mechanize'
    require 'uri'
    require 'net/http'
    require 'json'

    # レビューのリスト
    review_list = []
    therapists = User.where(user_role_id: 1, active_flag: 1).order(id: :ASC)
    therapists.each do |therapist|
      reviews = Review.where(display_flag: 1, user_id: therapist.id).order(post_date: :ASC)
      content = ""
      review_count = 0
      sequence_number = 1
      reviews.each do |review|
        content_tmp = review.formatted_review + "\n\n\n" + content
        if content_tmp.bytesize >= 10000 then
          review_list.push({
            system_user_id: therapist.id,
            sequence_number: sequence_number,
            review_count: review_count,
            review: content
          })
          content = review.formatted_review
          review_count = 1
          sequence_number += 1
        else
          content = content_tmp
          review_count += 1
        end
      end
      if content != "" then
        review_list.push({
          system_user_id: therapist.id,
          sequence_number: sequence_number,
          review_count: review_count,
          review: content
        })
      end
    end

    # 更新。
    Net::HTTP.post_form(URI(ENV["UPDATE_REVIEW_API"]), {token:ENV["UPDATE_REVIEW_TOKEN"], review_list:review_list.to_json})
  end
end
