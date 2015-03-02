let s:dir_base = expand("<sfile>:p:h")

let s:Env = {}
function! s:Env.new(line_s, line_e, mode) "{{{1
  let e = {
        \ "mode":    a:mode,
        \ "path":    self.set_path(),
        \ "buffer":  self.set_buffer(a:line_s, a:line_e),
        \ "content": self.set_content(a:line_s, a:line_e),
        \ }
  return extend(e, self)
endfunction

function! s:Env.toJSON() "{{{1
  try
    let env = filter(deepcopy(self), 'type(self[v:key]) isnot 2')
    let json = webapi#json#encode(env)
  catch /E117:/
    throw 'toJSON require "mattn/webapi-vim"'
  endtry
  return json
endfunction

function! s:Env.run(...) "{{{1
  let app = transform#_app()
  call call(app.run, a:000, app)
  throw 'SUCCESS'
endfunction

function! s:Env.get(...) "{{{1
  let app = transform#_app()
  call call(app.run, a:000, app)
  return self
endfunction

function! s:Env.set_path() "{{{1
  let R = {
        \ "dir_base": s:dir_base,
        \ "dir_transformer": join([s:dir_base, "transformer"], "/"),
        \ }
  return R
endfunction

function! s:Env.set_content(line_s, line_e) "{{{1
  let content = getline(a:line_s, a:line_e)
  if !len(content) || len(content) ==# 1 && empty(content[0])
    throw 'NO_CONTENT'
  endif
  let R = {
        \ "all":      content,
        \ "len":      len(content),
        \ "line_s-1": getline(a:line_s - 1),
        \ "line_s":   content[0],
        \ "line_e":   content[-1],
        \ "line_e+1": getline(a:line_e + 1),
        \ }
  function! R.update(content)
    let self.all = a:content
    let self.len = len(a:content)
  endfunction
  return R
endfunction

function! s:Env.set_buffer(line_s, line_e) "{{{1
  let bufname = bufname('')
  let R = {
        \ "filetype": &filetype,
        \ "filepath": fnamemodify(bufname, ':p'),
        \ "filename": fnamemodify(bufname, ':t'),
        \ "dirname":  fnamemodify(bufname, ':h'),
        \ "ext":      fnamemodify(bufname, ':e'),
        \ "cword":    expand('<cword>'),
        \ "cWORD":    expand('<cWORD>'),
        \ "pos":      getpos('.'),
        \ "bufnr":    bufnr(''),
        \ "line_s":   a:line_s,
        \ "line_e":   a:line_e,
        \ "line_s-1": a:line_s - 1,
        \ "line_e+1": a:line_e + 1,
        \ }
  return R
endfunction

" API:
function! transform#environment#new(...) "{{{1
  return call(s:Env.new, a:000, s:Env)
endfunction
" }}}
" vim: foldmethod=marker
