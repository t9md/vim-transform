input = STDIN.readlines
input.each do |l|
  puts l.chomp.split.map {|e| %!"#{e}"! }.join(", ")
end
