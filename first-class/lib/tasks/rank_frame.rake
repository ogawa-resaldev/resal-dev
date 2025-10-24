namespace :rank_frame do
  desc "rank_frame"
  task rank_frame: :environment do
    # reflection_dateを確認して、当該日であればuser_rankを反映。
    if UserRankReflectionDate.new.next_reflection_date == Date.today.strftime("%Y/%m/%d") then
      RanksHelper.reflectUserRank
    end
  end
end
