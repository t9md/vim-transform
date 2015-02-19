" Table to determine runner from file extention.
let s:lang2cmd = {
      \ "rb": "ruby",
      \ "py": "python",
      \ "pl": "perl",
      \ "sh": "sh",
      \ "go": "go run",
      \ }

" Default config
let s:default_conf = {}

function! s:default_conf._(e)
  return "_" . "/stringfy_word.rb"
endfunction

function! s:default_conf.go(e)
  let c = a:e.content
  let f = ''
  if c.line_s =~# '\v^const\s*\(' && c.line_e =~# '\v\)\s*'
    let f = "go/const_stringfy.rb"
  elseif c['line_s-1'] =~# '\v^import\s*\('
    let f = "go/import.rb"
  endif
  return f
endfunction

" Main
let s:T = {}

function! s:message(msg) "{{{1
  echom 'transform:' a:msg
endfunction

function! s:T.read_config() "{{{1
  let conf_user =
        \ exists('g:transform') && type(g:transform) ==# 4
        \ ? g:transform
        \ : {}
  let conf = extend({},   s:default_conf)
  return extend(conf, conf_user)
endfunction

function! s:T.determine_transformer() "{{{1
  let env  = self.env
  let conf = self.read_config()
  let R    = ''

  for ft in [ env.buffer.filetype, "_" ]
    unlet! F
    let F = get(conf, ft, '')
    if type(F) !=# 2
      continue
    endif
    let R = call(F, [env], conf)
    if !empty(R)
      break
    endif
  endfor
  if empty(R)
    throw 'CANT_DETERMINE_TRANSFORMER'
  endif

  if R[0] == '\v^/'
    return R
  endif
  return join([self.env.path.dir_transformer, R], "/")
endfunction

function! s:T.start(startline, endline, mode) "{{{1
  try
    let env = transform#environment#new(a:startline, a:endline, a:mode)
    let self.env = env
    let content = env.content
    let transformer = self.determine_transformer()
    let content.res = self.transform(transformer)
    call self.finish()
  catch
    call s:message(v:exception)
  endtry
endfunction

function! s:T.finish() "{{{1
  if self.env.mode ==# 'v'
    normal! gv"_d
  else
    normal! "_dd
  endif
  call append(self.env.buffer['line_s-1'], split(self.env.content.res, "\n"))
endfunction

function! s:T.get_cmd(tf) "{{{1
  if executable(a:tf)
    return a:tf
  endif

  let ext = fnamemodify(a:tf, ":t:e")
  let rc = get(s:lang2cmd, ext, '')
  if empty(rc)
    throw "CANT_DETERMINE_RUNNER"
  endif

  if !executable(rc)
    throw "RUNNER_NOT_EXCUTETABLE: " . rc
  endif
  return rc . ' ' . a:tf
endfunction

function! s:T.transform(tf) "{{{1
  let cmd   = self.get_cmd(a:tf)
  let stdin = join(self.env.content.all, "\n")
  return system(cmd, stdin)
endfunction

" Public API
" -----------------------------------------
function! transform#start(...) "{{{1
  call call(s:T.start, a:000, s:T)
endfunction

function! transform#default_config() "{{{1
  return deepcopy(s:default_conf)
endfunction
" }}}
" vim: foldmethod=marker
