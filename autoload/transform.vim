" Table to determine runner from file extention.
let s:lang2cmd = {
      \ "rb":     "ruby",
      \ "py":     "python",
      \ "pl":     "perl",
      \ "sh":     "sh",
      \ "go":     "go run",
      \ "coffee": "coffee",
      \ "js":     "node",
      \ }

" Default options
let s:options_default = {
      \ 'enable_default_config': 1,
      \ 'path': '',
      \ }

" Main
let s:T = {}
let s:helper = transform#helper#get()
let s:is_windows = has('win16') || has('win32') || has('win64') || has('win95')

function! s:status(msg) "{{{1
  if a:msg ==# 'SUCCESS'
    return
  endif
  echom 'transform:' a:msg
endfunction

function! s:T.read_config() "{{{1
  let conf = {}
  let conf_user =
        \ exists('g:transform') && type(g:transform) ==# 4
        \ ? g:transform
        \ : {}

  if !exists('conf_user.options') || type(conf_user.options) !=# 4
    let conf_user.options = {}
  endif
  call extend(conf_user.options, s:options_default, 'keep')

  if conf_user.options.enable_default_config
    call extend(conf,  transform#route#default())
  endif
  return extend(conf, conf_user)
endfunction

function! s:T.handle() "{{{1
  let handlers = [self.env.buffer.filetype, "_" ]

  for ft in handlers
    unlet! F
    let F = get(self.conf, ft, '')
    if type(F) !=# 2
      continue
    endif
    call call(F, [self.env], self.conf)
  endfor

  throw "NOTHING_TODO"
endfunction

function! s:T.find_transformer(filename)
  let path = join([self.conf.options.path, self.env.path.dir_transformer], ',')
  let found = split(globpath(path, a:filename), "\n")
  if empty(found)
    throw "TRANSFORMER_NOT_FOUND"
  endif
  return found[0]
endfunction

function! s:T.run(...) "{{{1
  try
    let [filename; other] = a:000

    let filename_with_slash = stridx(filename[1:],'/') !=# -1
    let transformer_path = filename_with_slash
          \ ? self.find_transformer(filename)
          \ : filename

    let cmd   = self.get_cmd(transformer_path)
    let stdin = self.env.content.all

    let self.env.content.res = system(cmd, stdin)

    " Experiment don't use
    if !empty(other) && exists('g:transform.helper_enable') && has_key(other[0], 'helper')
      call self.run_helper(other[0].helper)
    endif

    call self.write()
  finally
    throw "SUCCESS"
  endtry
endfunction

function! s:T.run_helper(helpers) "{{{1
  for helper in a:helpers
    let name = keys(helper)[0]
    let args = values(helper)[0]
    if has_key(self.helper, name)
      call call(self.helper[name], args, self)
    endif
  endfor
endfunction

function! s:T.start(...) "{{{1
  let [line_s, line_e, mode; other] = a:000
  try
    let self.env = transform#environment#new(line_s, line_e, mode)
    let self.env.app = self
    let self.helper = s:helper
    let self.conf = self.read_config()
    if len(other) ==# 1
      let transformer = other[0]
      call self.run(transformer)
    else
      call self.handle()
    endif
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
  if !s:is_windows && executable(a:tf)
    return a:tf
  endif

  let ext = fnamemodify(a:tf, ":t:e")
  let rc = get(s:lang2cmd, ext, '')

  if empty(rc) |
    throw "CANT_DETERMINE_RUNNER"
  endif
  if !executable(rc)
    throw "RUNNER_NOT_EXCUTETABLE: " . rc
  endif
  return rc . ' ' . a:tf
endfunction

" Public API
function! transform#start(...) "{{{1
  call call(s:T.start, a:000, s:T)
endfunction
" }}}
" vim: foldmethod=marker
