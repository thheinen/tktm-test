module TargetIO
  # 38/50 done
  module TrainCompat
    # 4/9 done (Blocked: 2x Mac, 3x Exotic, 6x common)
    class Dir
      # = homebrew_tap, homebrew_cask, archive_file, apt_repository, subversio, remote_directory, dsc_script, git, user/dscl, service/gentoo, service/aix, service/debian, service/macosx, serivice/insserv, package/msu
      # TODO
      class << self
        # TODO: chdir, mktmpdir, glob<-entries, pwd, home (Used in Resources)

        def delete(dir_name)
          ::ChefIO::Train::FileUtils.rm_rf(dir_name)
        end

        def directory?(dir_name)
          ::ChefIO::Train::File.directory? dir_name
        end

        def mkdir(dir_name, mode = nil)
          ::ChefIO::Train::FileUtils.mkdir_p(dir_name)
          ::ChefIO::Train::FileUtils.chmod(dir_name, mode) if mode
        end

        def unlink(dir_name)
          ::ChefIO::Train::FileUtils.rmdir(dir_name)
        end
    end
  end
end
