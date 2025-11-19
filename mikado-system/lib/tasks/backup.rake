namespace :backup do
  desc "backup important files"
  task backup: :environment do
    timestamp = Time.current.strftime("%Y-%m-%d_%H-%M-%S")
    # mysqldump。
    backup_file = "./tmp/backup/#{timestamp}_dump.sql.gz"
    `mysqldump -h #{ENV['DB_HOST']} -u #{ENV['DB_USERNAME']} -p#{ENV['DB_PASSWORD']} #{ENV['DB_NAME']} | gzip -c > #{backup_file}`

    # .envのバックアップ。
    `cp -p ./.env ./tmp/backup/.env_#{timestamp}`
  end
end
