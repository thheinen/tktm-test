module TargetIO
  class Etc
    class << self
      def method_missing(m, *args, &block)
        $logger.debug format('Etc::%s(%s)', m.to_s, args.join(', '))

        if ChefConfig::Config.target_mode? && !Chef::Client.transport_connection.os.unix?
          raise 'Etc support only on Unix, this is ' + Chef::Client.transport_connection.platform.title
        end

        backend = target_mode ? TrainCompat::Etc : ::Etc
        backend.send(m, *args, &block)
      end
    end
  end
end
