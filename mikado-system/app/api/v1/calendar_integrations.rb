module V1
  class CalendarIntegrations < Grape::API
    resources :calendar_integrations do
      # googleカレンダーの更新時にここを叩くことで、word pressに更新を伝播させるためのapi
      post '/propagate_google_calendar' do
        begin
          propagateGoogleCalendar(params)
        rescue => e
          raise StandardError.new("応募者の作成に失敗しました。(" + params["email-address"][0, 4] + "...)\n応募店舗グループは\n" + Store.find(params["system-store-id"]).store_group.name + "\nです。\n\nエラーは以下です。\n" + e.class.to_s + "\n" + e.message.to_s)
        end
      end
    end
  end
end
