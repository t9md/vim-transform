let s:dir_base = expand("<sfile>:p:h")

let s:Env = {}
function! s:Env.new(line_s, line_e, mode) "{{{1
  let self.mode = a:mode
  let self.path = self.set_path()
  let self.buffer = self.set_buffer(a:line_s, a:line_e)
  let self.content = self.set_content()
  return self
endfunction

function! s:Env.set_path() "{{{1
  let R = {
        \ "dir_base": s:dir_base,
        \ "dir_transformer": join([s:dir_base, "transformer"], "/"),
        \ }
  return R
endfunction

function! s:Env.set_content() "{{{1
  let content = getline(self.buffer.line_s, self.buffer.line_e)
  let R = {
        \ "all": content,
        \ "first-1": getline(self.buffer['line_s-1']),
        \ "first": content[0],
        \ "last": content[-1],
        \ "last+1": getline(self.buffer['line_e+1']),
        \ }
  return R
endfunction

function! s:Env.set_buffer(line_s, line_e) "{{{1
  let R = {
        \ "filetype": &filetype,
        \ "bufnr": bufnr(''),
        \ "line_s": a:line_s,
        \ "line_e": a:line_e,
        \ "line_s-1": a:line_s - 1,
        \ "line_e+1": a:line_e + 1,
        \ }
  return R
endfunction

function! transform#environment#new(...) "{{{1
  return call(s:Env.new, a:000, s:Env)
endfunction
" }}}
" vim: foldmethod=marker
