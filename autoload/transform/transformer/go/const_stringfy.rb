#!/usr/bin/env ruby
def parse(s)
  enums = []
  type = ""
  s.split("\n").each do |e|
    next if e =~ /\(|\)/
    n = e.split
    type << n[1] if n.size > 1
    enums << n.first
  end
  [type, enums]
end

def transform(s)
  type, enums = *parse(s)
  v = type[0].downcase

  out = ""
  enums.each do |e|
    out << "  case #{e}:\n"
    out << "    return \"#{e}\"\n"
  end
  return <<-EOS
#{s}

func (#{v} #{type}) String() string {
  switch #{v} {
#{out.chomp}
  default:
    return "Unknown"
  }
}
  EOS
end

# "const (\n\tRunning State = iota\n\tStopped\n\tRebooting\n\tTerminated\n)"
s = "const (
	Running State = iota
	Stopped
	Rebooting
	Terminated
)"

input = STDIN.read
if input =~ /\s*const/
  puts transform(input)
end

__END__

## Original

const (
	Running State = iota
	Stopped
	Rebooting
	Terminated
)

## Transform

const (
	Running State = iota
	Stopped
	Rebooting
	Terminated
)

func (s State) String() string {
  switch s {
  case Stopped:
    return "Stopped"
  case Rebooting:
    return "Rebooting"
  case Terminated:
    return "Terminated"
  default:
    return "Unknown"
  }
}
