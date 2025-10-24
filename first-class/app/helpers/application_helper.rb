module ApplicationHelper
  # RedcarpetとRedcarpet::Render::Stripを読み込む
  require 'redcarpet'
  require 'redcarpet/render_strip'

  # マークダウン形式のテキストをHTMLに変換するメソッド
  def markdown(text)
    # レンダリングのオプションを設定する
    render_options = {
      hard_wrap:       true,  # ハードラップを有効にする
      space_after_headers: true,  # ヘッダー後のスペースを有効にする
      fenced_code_blocks: true,  # フェンス付きコードブロックを有効にする
      with_toc_data: true # アンカーリンクを有効にする
    }

    # HTMLレンダラーを作成する
    renderer = Redcarpet::Render::HTML.new(render_options)

    # マークダウンの拡張機能を設定する
    extensions = {
      autolink:           true,  # 自動リンクを有効にする
      no_intra_emphasis:  true,  # 単語内の強調を無効にする
      fenced_code_blocks: true,  # フェンス付きコードブロックを有効にする
      lax_spacing:        true,  # 緩いスペーシングを有効にする
      strikethrough:      true,  # 取り消し線を有効にする
      superscript:        true  # 上付き文字を有効にする
    }

    # マークダウンをHTMLに変換し、結果をhtml_safeにする
    Redcarpet::Markdown.new(renderer, extensions).render(text).html_safe
  end

  # 全セラピストの一覧を返却する。
  def get_all_therapist_list
    therapist = {}
    require 'uri'
    require 'net/http'
    require 'json'
    @stores = Store.all
    @stores.each do |store|
      tmp_th = {}
      uri = URI.parse(store.store_url + 'wp-json/wp/v2/casts?per_page=100')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      response = http.get(uri)
      # たまに503がwpから返ってきてエラーになるので、0.1s間隔で10回試す。
      i = 0
      while i < 10 && response.code != "200"
        sleep(0.1)
        response = http.get(uri)
        i += 1
      end
      JSON.load(response.body).each do |res|
        tmp_th[res["id"]]={
          name:res["title"]["rendered"],
          link:res["link"]
        }
      end
      therapist[store.id]={
        name:store.store_name,
        therapist:tmp_th
      }
    end
    return therapist
  end

  # セラピストの一覧を返却する。(セラピスト、内勤の場合、関連したセラピストに絞る)
  def get_therapist_list
    therapist = {}
    require 'uri'
    require 'net/http'
    require 'json'
    @stores = Store.all
    @stores.each do |store|
      tmp_th = {}
      uri = URI.parse(store.store_url + 'wp-json/wp/v2/casts?per_page=100')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      response = http.get(uri)
      # たまに503がwpから返ってきてエラーになるので、0.1s間隔で10回試す。
      i = 0
      while i < 10 && response.code != "200"
        sleep(0.1)
        response = http.get(uri)
        i += 1
      end
      JSON.load(response.body).each do |res|
        tmp_th[res["id"]]={
          name:res["title"]["rendered"],
          link:res["link"]
        }
      end
      therapist[store.id]={
        name:store.store_name,
        therapist:tmp_th
      }
    end

    # ユーザーがセラピストだったら、紐づいた店舗idとセラピストidだけに絞る。
    if session[:user_role_id] == 1 then
      therapist_filtered_list = {}
      UserTherapist.where(user_id: session[:user_id]).each do |userTherapist|
        if not therapist_filtered_list.key?(userTherapist[:store_id]) then
          therapist_filtered_list[userTherapist[:store_id]] = {
            name:Store.find(userTherapist[:store_id])[:store_name],
            therapist:{}
          }
        end
        therapist_filtered_list[userTherapist[:store_id]][:therapist][userTherapist[:therapist_id]] = therapist[userTherapist[:store_id]][:therapist][userTherapist[:therapist_id]]
      end
      therapist = therapist_filtered_list
    # ユーザーが内勤だったら、所属している店舗グループ内の店舗idとそれに紐づいたセラピストidだけに絞る。
    elsif session[:user_role_id] == 3 then
      store_filtered_list = {}
      group_store_id_list = Store.where(store_group_id: BackOfficeGroup.find_by(user_id: session[:user_id])[:store_group_id]).pluck(:id)
      group_store_id_list.each do |group_store_id|
        store_filtered_list[group_store_id] = therapist[group_store_id]
      end
      therapist = store_filtered_list
    end
    return therapist
  end

  def sort_icon(column)
    if params[:sort_column].present? then
      if params[:sort_column] == column.to_s then
        if params[:sort_direction] == 'ASC' then
          return content_tag(:i, '', class: 'fa fa-sort-asc')
        else
          return content_tag(:i, '', class: 'fa fa-sort-desc')
        end
      end
    end
    return content_tag(:i, '', class: 'fa fa-unsorted')
  end

  # 数値をカンマ区切りにして返す。
  def number_format(number)
    if number.class == Integer then
      return number.to_formatted_s(:delimited)
    else
      return number
    end
  end
end
