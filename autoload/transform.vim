" Table to determine runner from file extention.
let s:lang2cmd = {
      \ "rb": "ruby",
      \ "py": "python",
      \ "pl": "perl",
      \ "sh": "sh",
      \ "go": "go run",
      \ }

" Main
let s:T = {}

function! s:status(msg) "{{{1
  if a:msg ==# 'SUCCESS'
    return
  endif
  echom 'transform:' a:msg
endfunction

function! s:T.read_config() "{{{1
  let conf_user =
        \ exists('g:transform') && type(g:transform) ==# 4
        \ ? g:transform
        \ : {}
  let conf = extend({},   transform#route#default())
  return extend(conf, conf_user)
endfunction

function! s:T.handle() "{{{1
  let conf = self.read_config()
  let R    = ''

  for ft in [ self.env.buffer.filetype, "_" ]
    unlet! F
    let F = get(conf, ft, '')
    if type(F) !=# 2
      continue
    endif
    let R = call(F, [self.env], conf)
  endfor

  throw "TRANSFORMER_NOT_FOUND"
endfunction

function! s:T.run(...) "{{{1
  try
    let args = a:000

    let filename = args[0]

    let transformer_path =
          \ filename[0] == '\v^/' ? filename :
          \ join([self.env.path.dir_transformer, filename], "/")

    let cmd   = self.get_cmd(transformer_path)
    let stdin = join(self.env.content.all, "\n")
    let self.env.content.res = system(cmd, stdin)
    call self.write()
  finally
    throw "SUCCESS"
  endtry
endfunction

function! s:T.start(startline, endline, mode) "{{{1
  try
    let self.env = transform#environment#new(a:startline, a:endline, a:mode)
    let self.env.app = self
    call self.handle()
  catch
    call s:status(v:exception)
  endtry
endfunction

function! s:T.write() "{{{1
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
function! transform#start(...) "{{{1
  call call(s:T.start, a:000, s:T)
endfunction
" }}}
" vim: foldmethod=marker
