module TargetIO
  class File
    class << self
      def method_missing(m, *args, &block)
        $logger.debug format('File::%s(%s)', m.to_s, args.join(', '))

        backend = ChefConfig::Config.target_mode? ? TrainCompat::File : ::File
        backend.send(m, *args, &block)
      end
    end
  end
end
