let s:T = {}
let s:dir_root = expand("<sfile>:p:h")

function! s:T.start(startline, endline, mode)
  let env = transform#environment#new(a:startline, a:endline, a:mode)
  let self.env = env

  let content = env.content
  if content.first =~# '\v^const\s*\('
    let f = "go/const_stringfy.rb"
  elseif content['first-1'] =~# '\v^import\s*\('
    let f = "go/import.rb"
  else
    let f = "_/stringfy_word.rb"
  endif

  if !len(content.all)
    return
  endif

  let output = self.run_filter(f)
  if empty(output)
    return
  endif

  if env.mode ==# 'v'
    normal! gv"_d
  else
    " linewise
    normal! "_dd
  endif
  call append(a:startline-1, split(output, "\n"))
endfunction

function! s:T.run_filter(filter)
  let output = ""
  let filter = join([self.env.path.dir_transformer, a:filter], "/")
  return system('ruby ' . filter , join(self.env.content.all, "\n"))
endfunction

function! transform#start(...) "{{{1
  call call(s:T.start, a:000, s:T)
endfunction
