module Transformer
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
        return r.map { |e| %!\t"#{e}"! }.join("\n").chomp
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
end
