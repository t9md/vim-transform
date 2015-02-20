" Default config
let s:route = {}

function! s:route._(e) "{{{1
  call a:e.run("_/stringfy_word.rb")
endfunction

function! s:route.go(e) "{{{1
  let e = a:e
  let c = e.content
  if c.line_s =~# '\v^const\s*\(' && c.line_e =~# '\v\)\s*'
    call e.run("go/const_stringfy.rb")
  elseif c['line_s-1'] =~# '\v^import\s*\('
    call e.run("go/import.rb")
  endif
endfunction

function! transform#route#default()
  return s:route
endfunction
