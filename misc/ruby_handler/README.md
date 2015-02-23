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
Bang! you got environment json dumped as `pp()` in buffer.  

```sh
env!!_<= YOUR_CURSOR_HERE
```
