# Example Ruby handler
This is merely example to show power of transformer.

## Setup
```sh
mkdir ~/transformer
cp -a ruby_handler ~/transformer
```

copy & paste content of `config.vim` in your `.vimrc`

## What infomration is available in handler?
As much infomation as Vim's handler.  
JSON serialized `env` is passed to first line of STDIN.  
In this example handler.rb.  
You can check this `env` variable like following.  

```sh
touch sandbox.rb
vim sandbox.rb
```
in Vim's buffer, input `env!!` as-is then trigger invoke `<Plug>(transform)`.  

```sh
env!!_<= YOUR_CURSOR_HERE and invoke Transformer
```
Bang! you got environment json dumped as `pp()` in buffer.  
The vim's function can't be serialized, so `env["get"]`, `env["new"]` etc are zeroed, you can simply ignore this.  
Now you can start modifying handler.rb as you like, edit handler.rb and check how routing and transformer invoking like.  
```ruby
{"get"=>0,
 "path"=>
  {"dir_base"=>"/Users/tmaeda/.vim/bundle/vim-transform/autoload/transform",
   "dir_transformer"=>
    "/Users/tmaeda/.vim/bundle/vim-transform/autoload/transform/transformer"},
 "new"=>0,
 "run"=>0,
 "mode"=>"n",
 "set_content"=>0,
 "set_buffer"=>0,
 "set_path"=>0,
 "toJSON"=>0,
 "buffer"=>
  {"line_s-1"=>0,
   "cWORD"=>"env!!",
   "line_e+1"=>2,
   "cword"=>"env",
   "filepath"=>"/Users/tmaeda/sandbox.rb",
   "line_s"=>1,
   "bufnr"=>1,
   "dirname"=>"/Users/tmaeda",
   "ext"=>"rb",
   "filetype"=>"ruby",
   "line_e"=>1,
   "pos"=>[0, 1, 1, 0],
   "filename"=>"sandbox.rb"},
 "content"=>
  {"line_e+1"=>"",
   "all"=>["env!!"],
   "len"=>1,
   "line_s"=>"env!!",
   "line_s-1"=>"",
   "line_e"=>"env!!",
   "update"=>0}}
```

