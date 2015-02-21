# This is sample handler to serve all request
# You can experiment, extend based on this sample.
# For configuration of vim side, refer config.vim in same directory.

class TF
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

module Go
  class Import
    def self.run(input)
      r = []
      repos = {
        gh: "github.com",
        cg: "code.google.com",
        gl: "golang.org",
      }

      input.each_line do |l|
        l.strip.split.map do |e|
          repos.each do |k, v|
            k = k.to_s
            if e =~ /^#{k}\//
              e = e.sub k, v
              break
            end
          end
          r << e
        end
      end
      puts r.map { |e| %!\t"#{e}"! }.join("\n").chomp
    end
  end

  class ConstStringfy
    class << self
      def parse(s)
        type = ""
        enums = []
        s.split("\n").each do |e|
          next if e =~ /\(|\)/
          n = e.split
          type << n[1] if n.size > 1
          enums << n.first
        end
        [type, enums]
      end

      def run(s)
        type, enums = *parse(s)
        v = type[0].downcase

        out = ""
        enums.each do |e|
          out << "\tcase #{e}:\n"
          out << "\t\treturn \"#{e}\"\n"
        end
        return <<-EOS
#{s}

func (#{v} #{type}) String() string {
\tswitch #{v} {
#{out.chomp}
\tdefault:
\t\treturn "Unknown"
\t}
}
        EOS
      end
    end
  end
end

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

input   = STDIN.read
input = input.split("\n", -1)

$env = {
  filename: ARGV[0],
  filetype: ARGV[1],
  'line_s-1' => input.shift,
  'line_e+1' => input.pop,
}

input = input.join("\n")



TF.register do
  if $env[:filetype] == 'go'
    if $env['line_s-1'] =~ /^import\s*\(/
      get /./ do |req|
        Go::Import.run(req)
      end
    end

    get /^const\s*\(/ do |req|
      puts Go::ConstStringfy.run(req)
    end
  end

  if $env[:filename] == "sample.md"
    get /^    \$(.*)$/ do |req, m|
      puts SimpleCommand.new(m[1]).run(req)
    end
  end

  # simply stringfy
  get /.*/ do |req|
    req.split("\n").map do |l|
      puts l.chomp.split.map {|e| %!"#{e}"! }.join(", ")
    end
  end
end

TF.start input
