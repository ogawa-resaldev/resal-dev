module V1
  module Helpers
      module TherapistHelper
        # セラピストの一覧を返却する。
        def get_therapist_list
          therapist = {}
          require 'uri'
          require 'net/http'
          require 'json'
          @stores = Store.all
          @stores.each do |store|
            tmp_th = {}
            uri = URI.parse(store.store_url + 'wp-json/wp/v2/users?per_page=100')
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = uri.scheme === "https"
            response = JSON.load(http.get(uri).body)
            response.each do |res|
              tmp_th[res["id"]]={
                name:res["name"]
              }
            end
            therapist[store.id]={
              name:store.store_name,
              therapist:tmp_th
            }
          end
          return therapist
        end
      end
  end
end
