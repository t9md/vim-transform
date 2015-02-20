# Dev Status
alpher release, gathering feedback from users.  
誰か試して、フィードバックちょうだい。  
<!-- VERY Experimental for my personal use. -->

# STDIN > transform > STDOUT

Thats' filter command.  
Filter command in other word => transformer.  
You can transform shorthand syntax within buffer on the fly.  

You can write transformer whichever language you want.  
This have great possibility to reduce typing!  

![Movie](https://raw.githubusercontent.com/t9md/t9md/019b944b5b1152dbb97b92471b7ec596769c8319/img/transform.gif)

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

## I don't like default transformer set,
Understood, you can disable it.  
NOTE: options name might change in future.  

```vim
let g:transform = {}
let g:transform.options = {}
let g:transform.options.disable_default_config = 1
```

## I don't need filetype spefic function, want to controll in one place.

Yes, you can. if you didn't define filtype specific handler, all transform request fall into `_` handler.  

```vim
let g:transform = {}
let g:transform.options = {}
let g:transform.options.disable_default_config = 1

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

# Ideally
Keep transformer script itself independent from editor, mean sharable between several editors.

# Need to consider
* command line arguments(or parameters) to transformer?
* Unite transformer

# Done
* Making excutable each transformer eliminate consideration by which programming ranguage transformer is written.
* determine appropreate run command like 'ruby', 'python', 'go run' from extention of each transfomer?
* choose appropriate set of transformer from `&filetype` => associated configurable function is called based on &ft.
* load user's transformer => if transformer' path is begin with '/', use as absolulte path.
* 100%: chosing appropriate transformer is hard, better to `do_what_I_mean` behavior by invoking controller and controller choose appropriate transformer from context(language and passed string).
* 100%: CofferScript will be great helper as transformer for its simple syntax to JavaScript syntax(some of which is legal in other language). => nothing to do, user's preference.

# TODO?
* 50%: make `:Transform` accept arg for directly specify transformer
*  0%: `:'<,'>!` is always linewise, you can't transform partial area within single line.
*  1%: good default config and tranformer set
* ??%: template engine like erb is better in most case?
* ??%: Whats' defference in advanced snipett plugin?(maybe this is way simple).
* 30%: Make multiple tranformer chainable so that we can  stringfy then surround by `import(` and `)`.
* ??%: Transformer Specification? when first arg is 'check', it shoud return 1 or 0 which is used by controller to determine appropreate transformer.
