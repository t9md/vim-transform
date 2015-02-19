input = STDIN.readlines
input.each do |l|
  nl = l.delete!("\n")
  print %!"#{l.strip}"!
  puts "\n" if nl
end
