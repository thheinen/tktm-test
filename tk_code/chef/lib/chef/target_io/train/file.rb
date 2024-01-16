module TargetIO
    module TrainCompat
      class File
        # missing (3): foreach(->Dir.glob/entries), realpath, utime(=mtime?),readable?, writable?
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
              Chef::Log.debug 'File::' + m.to_s + ' passed to Train.file.' + m.to_s

              file_name, other_args = args[0], args[1..]

              file = __transport_connection.file(file_name)
              file.send(m, *other_args) # block?

            elsif filestat.include? m
              Chef::Log.debug 'File::' + m.to_s + ' passed to Train.file.stat.' + m.to_s

              __transport_connection.file(args[0]).stat[m]

            elsif redirect.key?(m)
              Chef::Log.debug 'File::' + m.to_s + ' redirected to Train.file.' + redirect[m].to_s

              file_name, other_args = args[0], args[1..]

              file = __transport_connection.file(file_name)
              file.send(redirect[m], *other_args) # block?

            else
              raise 'Unsupported File method ' + m.to_s
            end
          end

          def __transport_connection
            Chef.run_context&.transport_connection
          end
        end
      end
    end
  end
