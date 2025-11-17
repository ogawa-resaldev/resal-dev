class WikiController < ApplicationController
  layout 'wiki'
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: :index

  def index
    @wiki_content = File.read(Rails.root.join('wiki_content', 'usage_' + params[:role] + '.md'))
  end
end
