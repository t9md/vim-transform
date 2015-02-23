let g:transform = {}
let g:transform.options = {}
let g:transform.options.enable_default_config = 0
let g:transform.options.path = "$HOME/transformer"

function! g:transform._(e)
  " To avoid mess in passing `env` as argment.
  " We serialize env to JSON and pass as first line of STDIN.
  " handler.rb should pop first line of STDIN and decode as JSON.
  " rest of STDIN is original STDIN in handler.rb
  let STDIN = [a:e.toJSON()] + a:e.content.all
  call a:e.content.update(STDIN)
  call a:e.run('ruby_handler/handler.rb')
endfunction
