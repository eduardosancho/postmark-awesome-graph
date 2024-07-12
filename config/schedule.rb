set :output, "log/cron_log.log"
set :environment, "development"

# every 1.minute do
every 1.day, at: '12:00 am' do
  rake "snapshot:take"
end