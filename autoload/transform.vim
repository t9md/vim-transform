" table to determine runner from file extention.
" -----------------------------------------
let s:lang2cmd = {
      \ "rb": "ruby",
      \ "py": "python",
      \ "pl": "perl",
      \ "sh": "sh",
      \ "go": "go run",
      \ }

" Sample config
" -----------------------------------------
let s:default = {}

function! s:default._(e)
  return "_" . "/stringfy_word.rb"
endfunction

function! s:default.go(e)
  let c = a:e.content
  let f = ''
  if c.first =~# '\v^const\s*\('
    let f = "go/const_stringfy.rb"
  elseif c['first-1'] =~# '\v^import\s*\('
    let f = "go/import.rb"
  endif
  return f
endfunction


" Main
" -----------------------------------------
let s:T = {}
function! s:T.start(startline, endline, mode) "{{{1
  let env = transform#environment#new(a:startline, a:endline, a:mode)
  let self.env = env
  let content = env.content

  if !len(content.all)
    return
  endif

  let conf_user = exists('g:transform') && type(g:transform) ==# 4 ? g:transform : {}
  let conf = extend(deepcopy(s:default), conf_user)
  let f = ''
  for ft in [ env.buffer.filetype, "_" ]
    unlet! F
    let F = get(conf, ft, '')
    if type(F) ==# 2
      let f = call(F, [env], conf)
    else
      continue
    endif
    if !empty(f)
      break
    endif
  endfor
  if empty(f)
    return
  endif

  let output = self.transform(f)
  if empty(output)
    return
  endif

  if env.mode ==# 'v'
    normal! gv"_d
  else
    normal! "_dd
  endif
  call append(a:startline-1, split(output, "\n"))
endfunction

function! s:T.find_transformer(transformer) "{{{1
  if a:transformer[0] == '/'
    return a:transformer
  endif
  return join([self.env.path.dir_transformer, a:transformer], "/")
endfunction

function! s:T.get_cmd(ft) "{{{1
  let ext = fnamemodify(a:ft, ":t:e")
  let rc = get(s:lang2cmd, ext, '')
  let tf_path = self.find_transformer(a:ft)
  let cmd =
        \ executable(tf_path) ? tf_path :
        \ !empty(rc) && executable(rc) ? rc . ' ' . tf_path :
        \ ''
  return cmd
endfunction

function! s:T.transform(tf) "{{{1
  let cmd = self.get_cmd(a:tf)
  if empty(cmd)
    return ''
  endif
  let input = join(self.env.content.all, "\n")
  return system(cmd, input)
endfunction

" Public API
" -----------------------------------------
function! transform#start(...) "{{{1
  call call(s:T.start, a:000, s:T)
endfunction

function! transform#default_config() "{{{1
  return deepcopy(s:default)
endfunction
" }}}
" vim: foldmethod=marker
