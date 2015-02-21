module Transformer
  module Base
    class SimpleCommand
      def initialize(command)
        @command = command
      end
      def run(input)
        IO.popen(@command, "r+") do |io|
          io.puts input
          io.close_write
          io.read
        end
      end
    end

    class StringfyWord
      def self.run(input)
        r = []
        input.each_line do |l|
           r << l.chomp.split.map {|e| %!"#{e}"! }.join(", ")
        end
        r.join("\n")
      end
    end
  end
end
