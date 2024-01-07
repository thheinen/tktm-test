module TargetIO
  module TrainCompat
    class IO
      class << self
        def read(path)
          TargetIO::File.readlines(path)
        end
      end
    end
  end
end
