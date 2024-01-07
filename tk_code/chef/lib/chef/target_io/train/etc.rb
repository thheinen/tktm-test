module TargetIO
  module TrainCompat
    class Etc
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
