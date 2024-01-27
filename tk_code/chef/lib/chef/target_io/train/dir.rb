require_relative 'file'
require_relative 'fileutils'

module TargetIO
  module TrainCompat
    class Dir
      class << self
        # TODO: chdir, mktmpdir, glob<-entries, pwd, home (Used in Resources)

        def delete(dir_name)
          ::TargetIO::FileUtils.rm_rf(dir_name)
        end

        def directory?(dir_name)
          ::TargetIO::File.directory? dir_name
        end

        def mkdir(dir_name, mode = nil)
          ::TargetIO::FileUtils.mkdir(dir_name)
          ::TargetIO::FileUtils.chmod(dir_name, mode) if mode
        end

        def unlink(dir_name)
          ::TargetIO::FileUtils.rmdir(dir_name)
        end

        def entries(dirname)
          cmd = "ls -1a #{dirname}"
          output = __run_command(cmd).stdout
          output.split("\n")
        end

        def __run_command(cmd)
          __transport_connection.run_command(cmd)
        end

        def __transport_connection
          Chef.run_context&.transport_connection
        end
      end
    end
  end
end
