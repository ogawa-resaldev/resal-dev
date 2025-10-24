namespace :rotate do
  desc "rotate"
  task rotate: :environment do
    # cron.logのコピー
    cron_log = "#{Rails.root}/log/cron.log"
    if File.exist?(cron_log)
      timestamp = Time.current.strftime("%Y%m%d")
      rotated_cron_log = "#{Rails.root}/log/cron.log.#{timestamp}"
      FileUtils.mv(cron_log, rotated_cron_log)
    end

    require 'fileutils'
    require 'active_support'
    # development.logのrotate
    time = Time.current.weeks_ago(2).strftime('%Y%m%d%H%M%S')
    log_all = Dir.glob("#{Rails.root}/log/*")
    log_all.each do |i|
      if File.stat(i).mtime.strftime('%Y%m%d%H%M%S') < time
        FileUtils.rm_f(i)
      end
    end
    # backupのrotate
    backup_all = Dir.glob("#{Rails.root}/tmp/backup/*")
    backup_all.each do |i|
      if File.stat(i).mtime.strftime('%Y%m%d%H%M%S') < time
        FileUtils.rm_f(i)
      end
    end
  end
end
