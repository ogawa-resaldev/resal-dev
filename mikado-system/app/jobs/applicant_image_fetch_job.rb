# 応募者の画像を取得
class ApplicantImageFetchJob < ApplicationJob
  queue_as :default

  # ActiveJob標準のリトライ設定（Sidekiqなどのバックエンドでも動作）
  # wait: 1秒後に再試行、attempts: 最大3回
  retry_on StandardError, wait: 1.second, attempts: 3

  def perform(applicant_id)
    applicant = Applicant.find(applicant_id)
    images = nil

    # 画像取得
    3.times do |i|
      sleep(300)
      images = applicant.getLatestImages
      break if images.present?
    end

    if images.blank?
      return
    end

    # 画像が取得できた場合のみ保存
    case images.length
    when 1
      applicant.save_uploaded_file("image_one", images[0])
    else
      applicant.save_uploaded_file("image_one", images[0])
      applicant.save_uploaded_file("image_two", images[1])
    end
  end

  private def getLatestImages(applicant)
    applicant.getLatestImages(applicant)
  end
end
