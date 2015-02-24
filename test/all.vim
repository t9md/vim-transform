function! s:report(subject, result) "{{{1
  echo '" ' . a:subject
  echo '" --------------------------------------------------------------'
  echo PP(a:result)
  echo ""
endfunction

let s:T = {}

function! s:T.env() "{{{1
  return transform#environment#new(1, 5, 'n')
endfunction

function! s:T.config() "{{{1
  unlet! g:transform
  call s:report('[config] g:transform not exist', transform#config())

  unlet! g:transform
  let g:transform = {}
  let g:transform.options = {}
  let g:transform.options.enable_default_config = 0
  call s:report('[config] dsiable default route', transform#config())

  unlet! g:transform
  let g:transform = {}
  function g:transform.rb()
  endfunction
  call s:report('g:transform have not options field', transform#config())

  unlet! g:transform
  let g:transform = {}
  let g:transform.options = {}
  call s:report('g:transform.options is not dictionary', transform#config())
endfunction

function! s:T._app() "{{{1
  return transform#_app()
endfunction

function! s:T._run() "{{{1
  for test in [ "config", "env", "_app"]
    unlet! R
    let R = call(self[test], [], self)
    call s:report(test, R)
  endfor

endfunction

call s:T._run()
