let s:lang2cmd = {
      \ "rb": "ruby",
      \ "py": "python",
      \ "pl": "perl",
      \ "sh": "sh",
      \ "go": "go run",
      \ }

let s:T = {}
function! s:T.start(startline, endline, mode) "{{{1
  let env = transform#environment#new(a:startline, a:endline, a:mode)
  let self.env = env
  let content = env.content

  if !len(content.all)
    return
  endif

  if content.first =~# '\v^const\s*\('
    let f = "go/const_stringfy.rb"
  elseif content['first-1'] =~# '\v^import\s*\('
    let f = "go/import.rb"
  else
    let f = "_/stringfy_word.rb"
    " let f = "_/date_time.py"
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

function! transform#start(...) "{{{1
  call call(s:T.start, a:000, s:T)
endfunction
" }}}
" vim: foldmethod=marker
