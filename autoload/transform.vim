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
let s:helper = transform#helper#get()

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
  if !exists('conf_user.options')
    let conf_user.options = {}
  endif

  if s:get_options(conf_user.options, 'disable_default_config') !=# 1
    call extend(conf,  transform#route#default())
  endif
  return extend(conf, conf_user)
endfunction

function! s:get_options(options, key)
  if has_key(a:options, a:key)
    return a:options[a:key]
  endif
  return -1
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

  throw "TRANSFORMER_NOT_FOUND"
endfunction

function! s:T.run(...) "{{{1
  try
    let [filename; other] = a:000

    let transformer_path =
          \ filename[0] ==# '/' ? filename :
          \ join([self.env.path.dir_transformer, filename], "/")

    let cmd   = self.get_cmd(transformer_path)
    let stdin = join(self.env.content.all, "\n")
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
