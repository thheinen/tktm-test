module TargetIO
  # 38/50 done
  module TrainCompat
    # 0/4 done (Blocked: 2x Mac, 2x Exotic, 4x common)
    class Etc
      # = git, group, user, subversion, service/systemd, launchd, service/macosx, package/homebrew
      # TODO: Read /etc/passwd and /etc/group on first access + return
      @@cache = {}

      class << self
        # TODO: getpwuid, getpwnam, getgrgid, getgrnam

        def __read
          %w[/etc/passwd /etc/group].each do |filename|
            @@cache[filename] = Chef::Client.transport_connection.file(filename).content
          end
        end
      end
    end
  end
end
