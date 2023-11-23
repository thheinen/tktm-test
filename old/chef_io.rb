require 'train'
require 'logger'

$logger = Logger.new(STDOUT)
$logger.level = Logger::DEBUG

module ChefConfig
  class Config
    def self.target_mode?
      $remote
    end
  end
end

class Chef
  class Client
    def self.transport_connection
      @@transport_connection ||= Train.create('local').connection
    end
  end
end

Chef::Client.transport_connection

####################################################################################################################################################################################################

require 'stringio' unless defined?(StringIO)

module ChefIO
  class Dir
    class << self
      def method_missing(m, *args, &block)
        target_mode = $remote
        $logger.debug format('File::%s(%s)', m.to_s, args.join(', '))

        backend = target_mode ? Train::Dir : ::Dir
        backend.send(m, *args, &block)
      end
    end
  end

  class Etc
    class << self
      def method_missing(m, *args, &block)
        $logger.debug format('File::%s(%s)', m.to_s, args.join(', '))

        if ChefConfig::Config.target_mode? && !Chef::Client.transport_connection.os.unix?
          raise 'Etc support only on Unix, this is ' + Chef::Client.transport_connection.platform.title
        end

        backend = target_mode ? Train::Etc : ::Etc
        backend.send(m, *args, &block)
      end
    end
  end

  class File
    class << self
      def method_missing(m, *args, &block)
        $logger.debug format('File::%s(%s)', m.to_s, args.join(', '))

        backend = ChefConfig::Config.target_mode? ? Train::File : ::File
        backend.send(m, *args, &block)
      end
    end
  end

  class FileUtils
    class << self
      def method_missing(m, *args, &block)
        $logger.debug format('FileUtils::%s(%s)', m.to_s, args.join(', '))

        backend = ChefConfig::Config.target_mode? ? Train::FileUtils : ::FileUtils
        backend.send(m, *args, &block)
      end
    end
  end

  # 38/50 done
  module Train
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

    # 24/27 done (Blocked: 1x Exotic, 2x common)
    class File
      # done (24): dir,exist,expand_path,join,basename,read,dirname,readlines,open,split,file?,directory?,mtime,extname,size,delete,binread,executable?,symlink?,blockdev?,chardev?,pipe?,socket?,file?
      # missing (3): foreach(->Dir.glob/entries), realpath, utime(=mtime?),readable?, writable?
      # = mount, service/gentoo, file!
      class << self
        # TODO: new

        @@files = {}

        def binread(name, length = nil, offset = 0)
          content = readlines(file_name)
          length = content.size - offset if length.nil?

          content[offset, length]
        end

        def delete(file_name)
          cmd = format('rm %<file>s', file_name)
          __transport_connection.run_command(cmd)
        end

        # TODO: ~ and relative expansion -> Cptn. Context
        # almost exclusively used with absolute __dir__ or __FILE__ though
        def expand_path(file_name, dir_string = "")
          # Chef::Util::PathHelper.join ?

          require 'pathname' unless defined?(Pathname)

          # Will just collapse relative paths inside
          pn = Pathname.new File.join(dir_string, file_name)
          clean = pn.cleanpath
        end

        # Needs to hook into io.close (Closure?)
        def new(filename, mode = "r")
          raise NotImplementedError, 'ChefIO::Train::File.new is still TODO'
        end

        # TODO: non-block && mode != 'r'
        def open(file_name, mode = "r")
          # Would need to hook into io.close (Closure?)
          raise 'Hell' if mode != 'r' && !block_given?

          content = readlines(file_name)
          new_content = content.dup

          io = StringIO.new(new_content)

          if mode.start_with? 'w'
            io.truncate(0)
          elsif mode.start_with? 'a'
            io.seek(0, IO::SEEK_END)
          end

          if block_given?
            yield(io)

            if (content != new_content) && !mode.start_with?('r')
              __transport_connection.file(file_name).content = new_content # Need Train 2.5+
              @@file[file_name] = new_content
            end
          end

          io
        end

        def readlines(file_name)
          @@files[file_name] ||= __transport_connection.file(file_name).content
        end

        ### START Could be in Train::File::...

        def executable?(file_name)
          mode(file_name) & 0111 != 0
        end

        # def ftype(file_name)
        #   case type(file_name)
        #   when :block_device
        #     "blockSpecial"
        #   when :character_device
        #     "characterSpecial"
        #   when :symlink
        #     "link"
        #   else
        #     type(file_name).to_s
        #   end
        # end

        # def readlink(file_name)
        #   raise Errno::EINVAL unless symlink?(file_name)

        #   link_path = link_path(file_name)
        #   basename(link_path)
        # end

        # def setgid?(file_name)
        #   mode(file_name) & 04000 != 0
        # end

        # def setuid?(file_name)
        #   mode(file_name) & 02000 != 0
        # end

        # def sticky?(file_name)
        #   mode(file_name) & 01000 != 0
        # end

        # def size?(file_name)
        #   exist?(file_name) && size(file_name) > 0
        # end

        # def world_readable?(file_name)
        #   mode(file_name) & 0001 != 0
        # end

        # def world_writable?(file_name)
        #   mode(file_name) & 0002 != 0
        # end

        # def zero?(file_name)
        #   exists?(file_name) && size(file_name) == 0
        # end

        ### END: Could be in Train

        # passthrough to Train Connection/file
        def method_missing(m, *args, &block)
          nonio    = %i[extname join dirname path split]

          passthru = %i[basename directory? exist? exists? file? mtime pipe? size socket? symlink?] # gid uid
          redirect = {
            blockdev?: :block_device?,
            chardev?: :character_device?
          }
          filestat = %i[mtime] #mode

          # In Train but not File/File::Stat:
          # group link_path linked_to? mode? owner selinux_label shallow_link_path type grouped_into? mounted sanitize_filename unix_mode_mask

          if nonio.include? m
            ::File.send(m, *args) # block?

          elsif passthru.include? m
            $logger.debug 'File::' + m.to_s + ' passed to Train.file.' + m.to_s

            file_name, other_args = args[0], args[1..]

            file = __transport_connection.file(file_name)
            file.send(m, *other_args) # block?

          elsif filestat.include? m
            $logger.debug 'File::' + m.to_s + ' passed to Train.file.stat.' + m.to_s

            __transport_connection.file(args[0]).stat[m]

          elsif redirect.key?(m)
            $logger.debug 'File::' + m.to_s + ' redirected to Train.file.' + redirect[m].to_s

            file_name, other_args = args[0], args[1..]

            file = __transport_connection.file(file_name)
            file.send(redirect[m], *other_args) # block?

          else
            raise 'Unsupported File method ' + m.to_s
          end
        end

        def __transport_connection
          Chef::Client.transport_connection
        end
      end
    end

    # 10/10 done
    class FileUtils
      # done: cp, rm, mkdir_p, chown, remove_entry, rm_rf, mv, rm_r, chmod, touch
      # missing: -
      # Only Unix right now!
      # (All commands are copied 1:1 from FileUtils source)
      class << self
        def chmod(mode, list, noop: nil, verbose: nil)
          cmd = sprintf('chmod %s %s', __mode_to_s(mode), list.join(' '))

          $logger.debug cmd if verbose
          return if noop

          __run_command(cmd)
        end

        def chmod_R(mode, list, noop: nil, verbose: nil, force: nil)
          cmd = sprintf('chmod -R%s %s %s', (force ? 'f' : ''), mode_to_s(mode), list.join(' '))

          $logger.debug cmd if verbose
          return if noop

          __run_command(cmd)
        end

        def chown(user, group, list, noop: nil, verbose: nil)
          cmd = sprintf(('chown %s %s', (group ? "#{user}:#{group}" : user || ':'), list.join(' ')))

          $logger.debug cmd if verbose
          return if noop

          __run_command(cmd)
        end

        def chown_R(user, group, list, noop: nil, verbose: nil, force: nil)
          cmd = sprintf('chown -R%s %s %s', (force ? 'f' : ''), (group ? "#{user}:#{group}" : user || ':'), list.join(' '))

          $logger.debug cmd if verbose
          return if noop

          __run_command(cmd)
        end

        # cmp
        # collect_method
        # commands
        # compare_file
        # compare_stream

        alias_method :copy, :cp
        def cp(src, dest, preserve: nil, noop: nil, verbose: nil)
          cmd = "cp#{preserve ? ' -p' : ''} #{[src,dest].flatten.join ' '}"

          $logger.debug cmd if verbose
          return if noop

          __run_command(cmd)
        end

        def cp_lr(src, dest, noop: nil, verbose: nil, dereference_root: true, remove_destination: false)
          cmd = "cp -lr#{remove_destination ? ' --remove-destination' : ''} #{[src,dest].flatten.join ' '}"

          $logger.debug cmd if verbose
          return if noop

          __run_command(cmd)
        end

        def cp_r(src, dest, preserve: nil, noop: nil, verbose: nil, dereference_root: true, remove_destination: nil)
          cmd = "cp -r#{preserve ? 'p' : ''}#{remove_destination ? ' --remove-destination' : ''} #{[src,dest].flatten.join ' '}"

          $logger.debug cmd if verbose
          return if noop

          __run_command(cmd)
        end

        # getwd (alias pwd)
        # have_option?
        # identical? (alias compare_file)

        def install(src, dest, mode: nil, owner: nil, group: nil, preserve: nil, noop: nil, verbose: nil)
          cmd = "install -c"
          cmd << ' -p' if preserve
          cmd << ' -m ' << mode_to_s(mode) if mode
          cmd << " -o #{owner}" if owner
          cmd << " -g #{group}" if group
          cmd << ' ' << [src, dest].flatten.join(' ')

          $logger.debug cmd if verbose
          return if noop

          __run_command(cmd)
        end

        alias_method :link, :ln
        def ln(src, dest, force: nil, noop: nil, verbose: nil)
          cmd = "ln#{force ? ' -f' : ''} #{[src,dest].flatten.join ' '}"

          $logger.debug cmd if verbose
          return if noop

          __run_command(cmd)
        end

        alias_method :symlink, :ln_s
        def ln_s(src, dest, force: nil, noop: nil, verbose: nil)
          cmd = "ln -s#{force ? 'f' : ''} #{[src,dest].flatten.join ' '}"

          $logger.debug cmd if verbose
          return if noop

          __run_command(cmd)
        end

        def ln_sf(src, dest, noop: nil, verbose: nil)
          ln_s(src, dest, force: true, noop: noop, verbose: verbose)
        end

        def mkdir(list, mode: nil, noop: nil, verbose: nil)
          cmd = "mkdir #{mode ? ('-m %03o ' % mode) : ''}#{list.join ' '}"

          $logger.debug cmd if verbose
          return if noop

          __run_command(cmd)
        end

        alias_method :makedirs, :mkdir_p
        alias_method :mkpath, :mkdir_p
        def mkdir_p(list, mode: nil, noop: nil, verbose: nil)
          cmd = "mkdir -p #{mode ? ('-m %03o ' % mode) : ''}#{list.join ' '}"

          $logger.debug cmd if verbose
          return if noop

          __run_command(cmd)
        end

        def mv(src, dest, force: nil, noop: nil, verbose: nil, secure: nil)
          cmd = "mv#{force ? ' -f' : ''} #{[src,dest].flatten.join ' '}"

          $logger.debug cmd if verbose
          return if noop

          __run_command(cmd)
        end

        # options
        # options_of
        # pwd
        # remove
        # remove_entry_secure
        # remove_file

        def rmdir(list, parents: nil, noop: nil, verbose: nil)
          return if noop

          __run_command
        end

        def rm(list, force: nil, noop: nil, verbose: nil)
          cmd = "rm#{force ? ' -f' : ''} #{list.join ' '}"

          $logger.debug cmd if verbose
          return if noop

          __run_command(cmd)
        end

        def rm_f(list, force: nil, noop: nil, verbose: nil, secure: nil)
          rm(list, force: true, noop: noop, verbose: verbose)
        end

        def rm_r(list, force: nil, noop: nil, verbose: nil, secure: nil)
          cmd = "rm -r#{force ? 'f' : ''} #{list.join ' '}"

          $logger.debug cmd if verbose
          return if noop

          __run_command(cmd)
        end

        alias_method :remove_entry, :rm_rf
        alias_method :rmtree, :rm_rf
        alias_method :safe_unlink, :rm_rf
        def rm_rf(list, noop: nil, verbose: nil, secure: nil)
          rm_r(list, force: true, noop: noop, verbose: verbose, secure: secure)
        end

        def rmdir(list, parents: nil, noop: nil, verbose: nil)
          cmd = "rmdir #{parents ? '-p ' : ''}#{list.join ' '}"

          $logger.debug cmd if verbose
          return if noop

          __run_command(cmd)
        end

        def touch(list, noop: nil, verbose: nil, mtime: nil, nocreate: nil)
          return if noop

          __run_command "touch #{nocreate ? '-c ' : ''}#{t ? t.strftime('-t %Y%m%d%H%M.%S ') : ''}#{list.join ' '}"
        end

        # uptodate?

        def method_missing(m, *args, &block)
          raise 'Unsupported ' + self.class.to_s + ' method ' + m.to_s
        end

        private

        # TODO: Symbolic modes
        def __mode_to_s(mode)
          mode.to_s(8)
        end

        def __run_command(cmd)
          __transport_connection.run_command(cmd)
        end

        def __transport_connection
          Chef::Client.transport_connection
        end
      end
    end
  end
end

# 130 Resources, 90 Unix
# Blocked: <40 Windows, 4 Mac, 6 Exotic, 11 common => 70/90 Unix resources ~ 80% Coverage

$remote = true;
puts "  " + ChefIO::File.dirname('/etc/passwd').to_s
puts "  " + ChefIO::File.exist?('/etc/passwd').to_s
puts "  " + ChefIO::File.blockdev?('/etc/passwd').to_s
puts "  " + ChefIO::File.executable?('/bin/bash').to_s
puts "  " + ChefIO::File.size('/bin/bash').to_s
puts "  " + ChefIO::File.readlines('/etc/passwd').to_s
#ChefIO::File.open("/tmp/xyz2", "w") { |f| f.write '.' }
require'pry';binding.pry
puts
