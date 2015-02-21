let g:transform = {}
let g:transform.options = {}
let g:transform.options.enable_default_config = 0
let g:transform.options.path = "/Users/t9md/transformer"

function! g:transform._(e)
  let stdin = [a:e.content['line_s-1'] ] + a:e.content.all + [a:e.content['line_e+1']]
  call a:e.content.update(stdin)

  let fn = a:e.buffer.filename
  let ft = a:e.buffer.filetype
  let cmd = printf( "%s %s %s", '/usr/local/bin/transformer.rb', fn, ft)
  call a:e.run(cmd)
endfunction
