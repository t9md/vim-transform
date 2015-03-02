# This is example, you need to change as you like.

require 'json'
require 'pp'

require_relative './lib/transformer'
require_relative './lib/transformer/base'
require_relative './lib/transformer/go'

# first line of STDIN is JSON string which inlucde `env` information.
input       = STDIN.read
json, input = input.split("\n", 2)
$env        = JSON.parse(json)

TF        = Transformer
FILE_NAME = $env['buffer']['filename']
FILE_TYPE = $env['buffer']['filetype']

TF.register do
  if FILE_TYPE == 'go'
    if $env['content']['line_s-1'] =~ /^import\s*\(/
      get /./ do |req|
        puts TF::Go::Import.run(req)
      end
    end

    get /^const\s*\(.*\)$/m do |req|
      puts TF::Go::ConstStringfy.run(req)
    end
  end

  ## if filename is `sandbox.json` and line begin line is `env!!` only, dump $env to buffer
  if FILE_NAME == "sandbox.json" && $env['content']['len'] == 1
    get /^env!!$/ do
      pp $env
    end
  end

  if FILE_NAME == "tryit.md"
    # Insert content of URL
    get %r!^\s*https?://.*$! do |req, m|
      puts req
      system %!curl '#{req}'!
    end

    # Insert command output ( not necessarily transformed )
    # =====================================
    # Before: '|' indicate HOL
    # |     $ ls
    # After:
    # |     $ ls -l
    # |     total 32
    # |     -rw-r--r--  1 t9md  staff  9294 Feb 22 01:58 README.md
    # |     drwxr-xr-x  4 t9md  staff   136 Feb 20 16:31 autoload
    # |     drwxr-xr-x  5 t9md  staff   170 Feb 21 17:01 misc
    # |     drwxr-xr-x  3 t9md  staff   102 Feb 19 12:07 plugin
    # |     -rw-r--r--  1 t9md  staff  2640 Feb 20 00:54 tags
    #
    get /^    \$(.*)$/ do |req, m|
      puts req
      puts `#{m[1]}`.split("\n").map { |e| "    #{e}" }.join("\n")
    end

    # Send command to tmux's pane
    # =====================================
    # send `hostname` command to tmux's pane specified in bracket.
    #
    # Before:
    #
    # |!!tmux[0] hostname
    #
    # Side Effect:
    #
    # send `hostname` command to tmux's pane 0
    #
    # After: nothing changed
    #
    # |!!tmux[0] hostname
    #
    get /!!tmux\[(\d+)\] (.*)$/ do |req, m|
      cmd = %!tmux send-keys -t#{m[1]} "#{m[2]}" Enter!
      system cmd
    end
  end

  # stringfy
  get /.*/ do |req|
    puts TF::Base::StringfyWord.run(req)
  end
end

TF.start input
