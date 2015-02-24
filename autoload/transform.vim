" Table to determine runner from file extention.
let s:ext2run = {
      \ "rb":     "ruby",
      \ "py":     "python",
      \ "pl":     "perl",
      \ "sh":     "sh",
      \ "go":     "go run",
      \ "coffee": "coffee",
      \ "js":     "node",
      \ "lua":    "lua",
      \ }

let s:options_default = {
      \ 'enable_default_config': 1,
      \ 'path': '',
      \ }

" Utility:
" ------------------------------------------------
function! s:exists_Dictionary(var) "{{{1
  return exists(a:var) && s:is_Dictionary(eval(a:var))
endfunction

function! s:str_strip(s) "{{{1
  " strip leading and trailing whilte space
  return substitute(a:s, '\v(^\s*)|(\s*$)', '', 'g')
endfunction

function! s:define_type_checker() "{{{1
  " dynamically define s:is_Number(v)  etc..
  let types = {
        \ "Number":     0,
        \ "String":     1,
        \ "Funcref":    2,
        \ "List":       3,
        \ "Dictionary": 4,
        \ "Float":      5,
        \ }

  for [type, number] in items(types)
    let s = ''
    let s .= 'function! s:is_' . type . '(v)' . "\n"
    let s .= '  return type(a:v) ==# ' . number . "\n"
    let s .= 'endfunction' . "\n"
    execute s
  endfor
endfunction
"}}}
call s:define_type_checker()
unlet! s:define_type_checker

function! s:cmd_parse(cmd) "{{{1
  " split `cmd` to [bin, arg] like following
  " Example:
  "   ' /bin/ls -l '    => ['/bin/ls', ' -l']
  "   'grep -v "^\s*$"' => ['grep', ' -v "^\s*$"']
  "   '/bin/ls'         => ['/bin/ls', '']
  let cmd = s:str_strip(a:cmd)
  let i = stridx(cmd, ' ')
  if i ==# -1
    let bin = cmd
    let arg = ''
  else
    let bin =  strpart(cmd, 0, i)
    let arg =  strpart(cmd, i)
  endif
  return [bin, arg]
endfunction
"}}}

" Main:
" ------------------------------------------------
let s:T = {}
let s:is_windows = has('win16') || has('win32') || has('win64') || has('win95')

function! s:T.read_config() "{{{1
  " Prepare all configuration used in vim-transformer.
  let conf_user =
        \ s:exists_Dictionary('g:transform')
        \ ? g:transform
        \ : {}

  let conf = {}
  call extend(conf, conf_user)
  if !s:is_Dictionary(get(conf, 'options'))
    let conf.options = {}
  endif
  call extend(conf.options, s:options_default, 'keep')

  if conf.options.enable_default_config
    call extend(conf,  transform#route#default(), 'keep')
  endif
  return conf
endfunction

function! s:T.handle() "{{{1
  " Call handler function based on &filetype.
  let handlers = [self.env.buffer.filetype, "_" ]

  for handler in handlers
    unlet! TF
    let TF = get(self.conf, handler)
    if !s:is_Funcref(TF)
      continue
    endif
    call call(TF, [self.env], self.conf)
  endfor

  throw "NOTHING_TODO"
endfunction

function! s:T.select(cmds) "{{{1
  " Return command from list of command by let user choose one.
  "
  " IN:
  "   [ {'hello': 'echo hello'}, { 'bye': 'echo bye'} ]
  " OUT:
  "   chose 1 => 'echo hello'
  "   chose 2 => 'echo bye'
  "   chose 0 => throw 'OUT_OF_RANGE'
  "   chose 9 => throw 'OUT_OF_RANGE'
  let cmds = a:cmds
  let menu = ['Transform: ']
  let num2cmd = {}

  let i = 0
  let desc_longest = 0
  for D in cmds
    unlet! D
    if !s:is_Dictionary(D)
      continue
    endif

    let i += 1
    let [desc, cmd] = items(D)[0]
    let num2cmd[i] = cmd
    let desc_longest = max([desc_longest, len(desc)])
    let fmt =  "  %d: %-" . desc_longest . "s => '%s'"
    call add(menu, printf(fmt, i, desc, cmd))
  endfor

  let R =  get(num2cmd, inputlist(menu), '')
  if !empty(R)
    return R
  endif
  throw 'OUT_OF_RANGE'
endfunction

function! s:T.run(...) "{{{1
  " Execute transformer
  "  Selected area > STDIN > transformer > STDOUT > result
  " TF = transformer
  try
    let [_cmd; other] = a:000
    let cmd = s:is_String(_cmd) ? _cmd : self.select(_cmd)

    let [TF, TF_arg] = s:cmd_parse(cmd)

    let TF_path = self.path_resolv(TF)
    let cmd = executable(TF_path) && !s:is_windows
          \ ? TF_path
          \ : self.run_cmd(TF_path)

    let STDIN = self.env.content.all
    let result = system(cmd . TF_arg, STDIN)
    call self.env.content.update(split(result, '\n' ))
  endtry
endfunction

function! s:T.run_cmd(tf) "{{{1
  " Return command
  "  'foo.rb' => 'ruby foo'
  "  'bar.py' => 'python foo'
  let TF = a:tf
  let ext    = fnamemodify(TF, ":t:e")
  let run = get(s:ext2run, ext, '')

  if  empty(run)      | throw "CANT_DETERMINE_RUNNER"           | endif
  if !executable(run) | throw "RUNNER_NOT_EXECUTETABLE: " . run | endif
  return run . " " . TF
endfunction

function! s:T.path_resolv(filename) "{{{1
  " Resolv path of transformer
  let TF = expand(a:filename)
  let TF_include_slash = stridx(TF[1:],'/') !=# -1
  if TF[0] ==# '/' || !TF_include_slash
    " absolute path(begin with '/') or filename not inclulde '/'
    "  ex) /bin/ls, script.rb
    return TF
  endif

  " Search from user speficied directory and vim-transformer's directory.
  let dirs  = join([self.conf.options.path, self.env.path.dir_transformer], ',')
  let found = split(globpath(dirs, TF), "\n")
  if !empty(found)
    return found[0]
  endif
  throw "TRANSFORMER_NOT_FOUND"
endfunction

function! s:T.start(...) "{{{1
  " Setup env and conf and start!
  let [line_s, line_e; rest] = a:000
  let mode = line_s !=# line_e ? 'v' : 'n'
  let TF   = len(rest) ==# 1 ? rest[0] : ''
  try
    let self.env  = transform#environment#new(line_s, line_e, mode)
    let self.conf = self.read_config()

    if !empty(TF)
      " User explicitly specified transformer
      call self.run(TF)
      throw 'SUCCESS'
    endif

    call self.handle()

  catch /^SUCCESS/
    if !empty(self.env.content.all)
      call self.write()
    endif
  catch
    echom 'transform:' v:exception
  endtry
endfunction

function! s:T.write() "{{{1
  " Replace Vim's buffer with transoformed content.
  if self.env.mode ==# 'v'
    normal! gv"_d
  else
    normal! "_dd
  endif
  call append(self.env.buffer['line_s-1'], self.env.content.all)
  call setpos('.', self.env.buffer.pos)
endfunction

" Public API:
function! transform#start(...) "{{{1
  call call(s:T.start, a:000, s:T)
endfunction

function! transform#config() "{{{1
  return s:T.read_config()
endfunction

function! transform#_app() "{{{1
  " Internally use don't call this.
  return s:T
endfunction
" }}}
" vim: foldmethod=marker
