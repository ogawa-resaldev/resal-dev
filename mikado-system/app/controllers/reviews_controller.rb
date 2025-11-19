class ReviewsController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: [:new, :index, :edit]

  def new
    @title = "レビュー新規作成"

    @review = Review.new

    if flash[:review_params] != nil then
      @review.assign_attributes(flash[:review_params])
      @review.valid?
    end

    @therapist_autocomplete = []
    User.all_by_user(session[:user_id]).where(user_role_id: 1, active_flag: 1).each do |user|
      auto_complete = user.name
      if user.user_therapist_setting.auto_complete.present? then
        auto_complete += user.user_therapist_setting.auto_complete
      end
      @therapist_autocomplete.push([user.id, user.name, auto_complete])
    end

    @age_select = ["年齢秘密", "10代", "20代前半", "20代後半", "30代前半", "30代後半", "40代前半", "40代後半", "50代"]
  end

  def create
    @review = Review.new(review_params)
    @review.assign_attributes(
      display_flag: true
    )

    begin
      ActiveRecord::Base.transaction do
        # レビューの保存。
        @review.save!
      end

      # うまく作成できたら、wordpressテーブルも更新してからレビュー一覧に飛ぶ。
      ReviewsHelper.update_wp_reviews
      redirect_to("/reviews")
    rescue ActiveRecord::RecordInvalid => e
      flash[:review_params] = review_params
      redirect_to("/reviews/new")
    end
  end

  def index
    @title = "レビュー一覧"

    @therapist_autocomplete = []
    User.all_by_user(session[:user_id]).where(user_role_id: 1, active_flag: 1).each do |user|
      auto_complete = user.name
      if user.user_therapist_setting.auto_complete.present? then
        auto_complete += user.user_therapist_setting.auto_complete
      end
      @therapist_autocomplete.push([user.id, user.name, auto_complete])
    end

    @reviews = Review.all

    if params[:therapist_id].present? then
      @reviews = @reviews.where(user_id: params[:therapist_id])
    end
    @reviews = @reviews.where("? <= post_date", params[:post_date_from]) if params[:post_date_from].present?
    @reviews = @reviews.where("post_date <= ?", params[:post_date_to]) if params[:post_date_to].present?
    @reviews = @reviews.order("post_date DESC, id DESC")
    if params[:free_word].present?
      @reviews = @reviews.select{ |review|
        (review.nickname + review.content).include?(params[:free_word])
      }
    end
  end

  def edit
    @title = "レビュー編集"

    @review = Review.find(params[:id])
    if flash[:review_params] != nil then
      @review.assign_attributes(flash[:review_params])
      @review.valid?
    end

    @therapist_select = [["選択", ""]]
    User.where(active_flag: 1).each do |user|
      if user.user_role_id == 1 then
        @therapist_select.push([user.name, user.id])
      end
    end

    @age_select = ["年齢秘密", "10代", "20代前半", "20代後半", "30代前半", "30代後半", "40代前半", "40代後半", "50代"]
  end

  def update
    @review = Review.find(params[:id])
    begin
      ActiveRecord::Base.transaction do
        @review.update!(review_params)
      end

      # うまく更新できたら、wordpressテーブルも更新してからレビュー一覧に飛ぶ。
      ReviewsHelper.update_wp_reviews
      redirect_to("/reviews/"+params[:id]+"/edit")
    rescue ActiveRecord::RecordInvalid => e
      flash[:review_params] = review_params
      redirect_to("/reviews/"+params[:id]+"/edit")
    end
  end

  private def review_params
    params.require(:review).permit(
      :user_id,
      :reservation_name,
      :reservation_mail_address,
      :nickname,
      :age,
      :post_date,
      :content,
      :display_flag
    )
  end
end
