input = STDIN.readlines

r = []
repos = {
  gh: "github.com",
  cg: "code.google.com",
  gl: "golang.org",
}

input.each do |l|
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
