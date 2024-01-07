module TargetIO
  module TrainCompat
    class Dir
      class << self
        # TODO: chdir, mktmpdir, glob<-entries, pwd, home (Used in Resources)

        def delete(dir_name)
          ::TargetIO::Train::FileUtils.rm_rf(dir_name)
        end

        def directory?(dir_name)
          ::TargetIO::Train::File.directory? dir_name
        end

        def mkdir(dir_name, mode = nil)
          ::TargetIO::Train::FileUtils.mkdir_p(dir_name)
          ::TargetIO::Train::FileUtils.chmod(dir_name, mode) if mode
        end

        def unlink(dir_name)
          ::TargetIO::Train::FileUtils.rmdir(dir_name)
        end
      end
    end
  end
end
