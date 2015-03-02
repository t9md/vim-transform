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
touch sandbox.json
vim sandbox.json
```
in Vim's buffer, input `env!!` as-is then trigger invoke `<Plug>(transform)`.  

```sh
env!!_<= YOUR_CURSOR_HERE and invoke Transformer
```
Bang! You got environment json dumped by ruby's `pp()` to buffer.  
Now you can start modifying handler.rb as you like, edit handler.rb and check how routing and transformer invoking like.  

```json
{"path"=>
  {"dir_base"=>"/Users/t9md/.vim/bundle/vim-transform/autoload/transform",
   "dir_transformer"=>
    "/Users/t9md/.vim/bundle/vim-transform/autoload/transform/transformer"},
 "mode"=>"n",
 "content"=>
  {"line_e+1"=>"",
   "all"=>["env!!"],
   "len"=>1,
   "line_s"=>"env!!",
   "line_s-1"=>"",
   "line_e"=>"env!!",
   "update"=>0},
 "buffer"=>
  {"line_e+1"=>2,
   "bufnr"=>18,
   "pos"=>[0, 1, 5, 0],
   "cWORD"=>"env!!",
   "filepath"=>"/Users/t9md/sandbox.json",
   "line_s"=>1,
   "line_s-1"=>0,
   "ext"=>"json",
   "dirname"=>".",
   "line_e"=>1,
   "cword"=>"!!",
   "filetype"=>"json",
   "filename"=>"sandbox.json"}}
```
