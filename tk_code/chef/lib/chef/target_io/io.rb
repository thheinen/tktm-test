module TargetIO
  class Dir
    class << self
      def method_missing(m, *args, &block)
        target_mode = $remote
        $logger.debug format('IO::%s(%s)', m.to_s, args.join(', '))

        backend = target_mode ? TrainCompat::IO : ::IO
        backend.send(m, *args, &block)
      end
    end
  end
end
