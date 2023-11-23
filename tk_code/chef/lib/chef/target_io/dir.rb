module TargetIO
  class Dir
    class << self
      def method_missing(m, *args, &block)
        target_mode = $remote
        $logger.debug format('File::%s(%s)', m.to_s, args.join(', '))

        backend = target_mode ? TrainCompat::Dir : ::Dir
        backend.send(m, *args, &block)
      end
    end
  end
end
