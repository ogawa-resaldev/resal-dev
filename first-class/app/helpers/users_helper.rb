module UsersHelper
  # word pressに持っているsystem_therapistsテーブルをAPI経由で更新。
  def self.update_wp_therapists
    require 'mechanize'
    require 'uri'
    require 'net/http'
    require 'json'

    # system_user_id、セラピスト名、自動補完のリスト
    wp_therapist_list = {}
    @stores = Store.all
    @stores.each do |store|
      tmp_th = {}
      uri = URI.parse(store.store_url + 'wp-json/wp/v2/users?per_page=100')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      response = JSON.load(http.get(uri).body)
      response.each do |res|
        # システムに登録のないtherapistは、system_user_id = 0で登録される。
        tmp_th[res["id"]] = {"system_user_id": 0, "therapist_name": res["name"], "autocomplete": ""}
      end
      wp_therapist_list[store.id] = tmp_th
    end

    # セラピストのリスト
    therapist_list = []
    therapists = User.where(user_role_id: 1, active_flag: 1).order(id: :ASC)
    therapists.each do |therapist|
      user_therapists = UserTherapist.where(user_id: therapist.id)
      user_therapist_setting = UserTherapistSetting.find_by(user_id: therapist.id)
      user_therapists.each do |user_therapist|
        # システム上にセラピストの登録があれば、system_user_idとautocompleteを更新。
        if wp_therapist_list[user_therapist.store_id].key?(user_therapist.therapist_id) then
          wp_therapist_list[user_therapist.store_id][user_therapist.therapist_id][:system_user_id] = user_therapist_setting.user_id
          wp_therapist_list[user_therapist.store_id][user_therapist.therapist_id][:autocomplete] = user_therapist_setting.auto_complete
        end
      end
    end

    # therapist_listを作成。
    wp_therapist_list.each do |store_id, therapist|
      therapist.each do |therapist_id, therapist|
        therapist_list.push({
          system_store_id: store_id,
          therapist_id: therapist_id,
          system_user_id: therapist[:system_user_id],
          therapist_name: therapist[:therapist_name],
          autocomplete: therapist[:autocomplete]
        })
      end
    end

    # 更新。
    Net::HTTP.post_form(URI(ENV["UPDATE_THERAPIST_API"]), {token:ENV["UPDATE_THERAPIST_TOKEN"], therapist_list:therapist_list.to_json})
  end

  # ログイン情報メッセージの作成
  def self.create_login_information_message(therapist_name, login_id, password)
    message = therapist_name + "さん"
    message = message + "\n"
    message = message + "\n"
    message = message + "帝の予約/清算管理システムのログイン情報をお送りします。\n"
    message = message + "ぜひご活用ください！\n"
    message = message + "\n"
    message = message + "以下、ログイン情報です。(くれぐれも流出にはお気をつけください。また、定期的なパスワード変更をお勧めします。)\n"
    message = message + "\n"
    message = message + "・url\n"
    message = message + "https://system.mikadobar.shop/login\n"
    message = message + "\n"
    message = message + "・ログインID/パスワード\n"
    message = message + login_id + "/" + password + "\n"
    message = message + "\n"
    message = message + "ログインできましたら、まずはプロフィールの更新をお願いいたします。\n"
    message = message + "(メニューの「" + therapist_name + "/セラピスト」→「プロフィール」で編集画面にいきます。また、説明書もご確認いただければと思います。)\n"
    message = message + "・ユーザー名\n"
    message = message + "・パスワード\n"
    message = message + "・自動補完\n"
    message = message + "・メールアドレス\n"
    message = message + "・口座情報\n"
    message = message + "\n"
    message = message + "=====使用方法=====\n"
    message = message + "・予約の確認\n"
    message = message + "・清算一覧から振込を作成\n"
    message = message + "・振込日設定/振込確認\n"
    message = message + "→以下ドキュメントをご確認ください\n"
    message = message + "https://docs.google.com/document/d/1yNPcc1MqD9X53JE4F_9BpB7drhcxvgywSlwjCOcYYQ8/edit\n"
    message = message + "\n"
    message = message + "・雑費申請\n"
    message = message + "清算をまとめる際にバー報酬など計上されていないものがあった場合、「申請」→「雑費申請」で雑費の計上を依頼することが可能です。(店舗グループ、フローの方向にご注意ください)\n"
    message = message + "\n"
    message = message + "・帝コイン入出庫申請\n"
    message = message + "帝コインを使用して得点を受け取りたい場合や、加算が漏れている場合、「申請」→「帝コイン入出庫申請」で帝コインの入出庫の依頼が可能です。\n"
    message = message + "\n"
    message = message + "・実績の確認\n"
    message = message + "「" + therapist_name + "/セラピスト」→「実績」で実績の確認が可能です。未消化の予約についても表示されるので、セラピスト活動にお役立てください！\n"
    message = message + "==========\n"
    message = message + "\n"
    message = message + "また、もしログインできない場合や、ログインIDを変更したい場合は、お手数ですがその旨を運営にお教えください。\n"
    message = message + "他にも、システムのことで分からないことや改善点などありましたら遠慮なくご連絡ください。\n"
    message = message + "\n"
    message = message + "以上、長くなりましたが、ご確認/ご対応をお願いいたします。\n"

    return message
  end
end
