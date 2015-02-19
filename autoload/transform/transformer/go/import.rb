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
    %!"#{e}"!
  end
end
r = r.map do |e|
  %!\t"#{e}"!
end.join("\n").chomp
puts r
