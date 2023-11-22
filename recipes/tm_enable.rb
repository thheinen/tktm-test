# Only Test Resources which use shell_out or shell_out!

cron 'Good vibes' do
  command "echo 'good vibes'"
  time :daily
end

