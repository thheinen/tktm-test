# README

TODO

## Logging in `client.rb`

```ruby
    def run_ohai
      filter = Chef::Config[:minimal_ohai] ? %w{fqdn machinename hostname platform platform_version ohai_time os os_version init_package} : nil
      if Chef::Config.target_mode?
        ohai.transport_connection = transport_connection
        logger.warn('Running remote Ohai... please wait')
      end
      ohai.all_plugins(filter)
      events.ohai_completed(node)
    end
```

```ruby
      # Join arguments into a string.
      # 
      # If the argument ends with a whitespace, use it as-is. Otherwise, add
      # a space at the end
      # 
      # @param args [String] variable number of string arguments
      # @return [String] merged string
      #
      def __join_whitespace(*args)
        args.reduce { |output, e| output + (e.rstrip == e ? '' : ' ') + e }
      end

      def __shell_out_command(*args, **options)
        if __transport_connection
          # POSIX compatible (2.7.4)
          # FIXME: Should be in Train for parity, but would need to be in
          #        base_connection, which is a bit tough.
          if options[:input] && !ChefUtils.windows?
            args = Array(args)
            args.concat ["<<<'COMMANDINPUT'\n", options[:input] + "\n", "COMMANDINPUT\n"]
            logger.debug __join_whitespace(args)
          end

          FakeShellOut.new(args, options, __transport_connection.run_command(join_whitespace(args), options)) # FIXME: train should accept run_command(*args)
        else
      # ...

      class FakeShellOut
        attr_reader :stdout, :stderr, :exitstatus, :status

        def initialize(args, options, result)
          @args = args
          @options = options
          @stdout = result.stdout
          @stderr = result.stderr
          @exitstatus = result.exit_status
          @valid_exit_codes = options[:returns] || [0]
          @status = OpenStruct.new(success?: (@valid_exit_codes.include? exitstatus))
        end

        def error?
          @valid_exit_codes.none?(exitstatus)
        end

        def error!
          raise Mixlib::ShellOut::ShellCommandFailed, "Unexpected exit status of #{exitstatus} running #{@args}" if error?
        end
      end
```