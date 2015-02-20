# Dev Status
alpher release, gathering feedback from users.  

Give me feedback if you tried.  
誰か試して、フィードバックちょうだい。  

* [Twitter ID](https://twitter.com/t9md)

<!-- VERY Experimental for my personal use. -->

# STDIN > transform > STDOUT

Thats' filter command.  
Filter command in other word => transformer.  
You can transform shorthand syntax within buffer on the fly.  

You can write transformer whichever language you want.  
This have great possibility to reduce typing!  

![Movie](https://raw.githubusercontent.com/t9md/t9md/019b944b5b1152dbb97b92471b7ec596769c8319/img/transform.gif)

# Windows user?
~~Currently not supported.~~


## How it works

1. select area or simply post cursor where you want to transform.
2. buffer are piped to `STDIN` of transformer and read result from `STDOUT` of transformer
3. replace buffer with result.

# Config in vimrc

```vim
nmap <D-R> <Plug>(transform)
xmap <D-R> <Plug>(transform)
```
## Customize

You can set handler function to choose appropriate transformer based on context.  
`e` is environment variable, you can call `e.run(TRANSFORMER_NAME)`.  
NOTE: `e.run()` call never return, imediately finish after rewritten buffer.  

`g:transform` is Dictionary with `key=&filetype`, `value=Function`.  
The magical `_` function is like `default_route` which always be called after &filetype specific function didn't invoke `run()`.  

Your configuration will be merged into [default_conf](https://github.com/t9md/vim-transform/blob/master/autoload/transform/route.vim) by `extend(default_conf, user__conf)`

```vim
let g:transform = {}
let g:transform.options.enable_default_config = 0
let g:transform.options.path = "/Users/t9md/my_transformer"

function! g:transform._(e)
  call e.run("_/stringfy_word.rb")
endfunction

function! s:route.go(e) "{{{1
  let e = a:e
  let c = e.content
  if c.line_s =~# '\v^const\s*\(' && c.line_e =~# '\v\)\s*'
    call e.run("go/const_stringfy.rb")
  elseif c['line_s-1'] =~# '\v^import\s*\('
    call e.run("go/import.rb")
  endif
endfunction
```
### Advanced example

```vim
let g:transform = {}
let g:transform.options = {}
let g:transform.options.enable_default_config = 0
let g:transform.options.path = "/Users/t9md/transformer"

function! g:transform._(e)
  let e = a:e
  let c = e.content

  if e.buffer.filetype ==# 'go'
    if c.line_s =~# '\v^const\s*\(' && c.line_e =~# '\v\)\s*'
      call e.run("go/const_stringfy.rb")
    elseif c['line_s-1'] =~# '\v^import\s*\('
      call e.run("go/import.rb")
    endif
  endif

  if e.buffer.filetype =~# 'markdown'
    " Dangerous example
    " if line is four leading space and '$', then execute string after '$' char.
    "  ex) '    $ ls -l' => trasnsformed result of 'ls -l'

    let pat = '\v^    \$(.*)$'
    if c.len ==# 1 && c.line_s =~# pat
      let cmd = substitute(c.line_s, pat, '\1', '')
      call e.run(cmd)
    endif

    " replace URL to actual content
    if c.len ==# 1 && c.line_s =~# '\v^\s*https?://\S*$'
      call e.run('curl ' . c.line_s)
    endif
  endif

  if e.buffer.filename =~# 'translate.md'
    call e.run('google_translate.py')
  endif
  call e.run("_/stringfy_word.rb")
endfunction
```

## I don't like default transformer set,
Understood, you can disable it.  
NOTE: options name might change in future.  

```vim
let g:transform = {}
let g:transform.options = {}
let g:transform.options.enable_default_config = 0
```
## How vim-transform find transformer

if file begin with '/'(ex /bin/ls ) or filename not include '/'(ex some.py, some.rb) then find $PATH.  

A. absolute path ex) /bin/ls  
B. filename not include '/' ex) some.py some.rb  
C. filename include '/' in the middle of filenmae.  

for A, B, vim-transform pass command system() as-is, means use $PATH environment variable.  

for C, vim-transform search following order.  

1. user's transformer_ directory  
2. system default transformer directory  

You can set user's transformer directories with comma sepalated list of directory.  

```vim
let g:transform.options.path = "/Users/t9md/transformer,/Users/work/myfriend/transformer"
```

NOTE: As explained in C. you need '/' in flie name, this  

```vim
" filename include '/' try search from transformer dir
call e.run("go/const_stringfy.rb")

" since filename not include '/' not trying to search from tranformer directory.
call e.run("const_stringfy.rb")
```



## Want to change routing based on filename

Google translate only if file name include `translate.md`
```vim
if e.buffer.filename =~# 'translate.md'
  call e.run('google_translate.py')
endif
```

## I don't need filetype spefic function, want to controll in one place.

Yes, you can. if you disable default handler and didn't define filtype specific handler, all transform request fall into `_` handler.  

```vim
let g:transform = {}
let g:transform.options = {}
let g:transform.options.enable_default_config = 0

" you can use get filetype via env.buffer.filetype
function! g:transform._(e)
  let e = a:e
  let c = e.content

  if e.buffer.filetype ==# 'go'
    if c.line_s =~# '\v^const\s*\(' && c.line_e =~# '\v\)\s*'
      call e.run("go/const_stringfy.rb")
    elseif c['line_s-1'] =~# '\v^import\s*\('
      call e.run("go/import.rb")
    endif
  endif

  call e.run("_/stringfy_word.rb")
endfunction
```

## What is the `e` argument passed to `g:transform[&ft](e)` function?

This is environment vim-transform use.
You can see its value by

```vim
" requre vim-prettyprint to use PP()
" 1 = line_start, 10 = line_end, n = normal mode(use v for visual)
:echo PP(transform#environment#new(1, 10, 'n'))
```

example output of `environment`

```vim
{
  'buffer': {
    'bufnr': 53,
    'filetype': 'vim',
    'line_e': 5,
    'line_e+1': 6,
    'line_s': 1,
    'line_s-1': 0
  },
  'content': {
    'all': [
      'echo PP(transform#environment#new(1, 5, ''n''))',
      'finish',
      'let g:transform = {}',
      '',
      'function! g:transform._(e)'
    ],
    'line_s':
      'echo PP(transform#environment#new(1, 5, ''n''))',
    'line_s-1': '',
    'line_e': 'function! g:transform._(e)',
    'line_e+1': '  return "_" . "/stringfy_word.rb"'
  },
  'mode': 'n',
  'new': function('413'),
  'path': {
    'dir_base':
      '/Users/t9md/.vim/bundle/vim-transform/autoload/transform',
    'dir_transformer':
      '/Users/t9md/.vim/bundle/vim-transform/autoload/transform/transformer'
  },
  'set_buffer': function('416'),
  'set_content': function('415'),
  'set_path': function('414')
}
```

# once Ideally => now MUST
Keep transformer script itself independent from editor, mean sharable between several editors.

# TODO?
* ` 0%` currently input is always treated as linewise, support charwise to transform partial area within single line
* ` 1%` good default config and tranformer set?
* ` 0%` command line arguments(or parameters) to transformer?
* ` 0%` Unite transformer?
* `30%` Make multiple tranformer chainable so that we can stringfy then surround by `import(` and `)`.
  => curretly you can use pipe `|` in xNIX OS but need to exutable except first comand.

# Done
* `100%` support directly excutable transformer( except windows ).
* `100%` determine appropreate run command like 'ruby', 'python', 'go run' from extention of each transfomer?
  'ext => runner' table is not mature.
* `100%`choose appropriate set of transformer from `&filetype` => call appropriate handler function based on &ft.
* `100%` support arbitrary directory for user's transformer
* `100%` chosing appropriate transformer is hard, better to `do_what_I_mean` behavior by invoking controller and controller choose appropriate transformer from context(language and passed string).
* ` 50%` make `:Transform` accept arg for directly specify transformer

# DONT( once considered and decided not to do)
* Whats' defference in advanced snipett plugin?(maybe this is way simple).
* CofferScript will be great helper as transformer for its simple syntax to JavaScript syntax(some of which is legal in other language). => nothing to do, user's preference.
* Template engine like erb is better in most case? => you can by your own transformer.
* Transformer Specification? when first arg is 'check', it shoud return 1 or 0 which is used by controller to determine appropreate transformer. => STDIN > STDOUT that's all. KISS.
