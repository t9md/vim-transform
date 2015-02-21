# This is sample handler to serve all request
# You can experiment, extend based on this sample.
# For configuration of vim side, refer config.vim in same directory.
module Transformer
  class <<  self
    def get(condition, &blk)
      handlers.push([condition, blk])
    end

    def handlers
      @handlers ||= []
      @handlers
    end

    def register(&blk)
      instance_eval(&blk)
    end

    def start(input)
      @handlers.each do |regexp, blk|
        m = regexp.match(input)
        if m
          blk.call(input, m)
          return
        end
      end
    end
  end
end
