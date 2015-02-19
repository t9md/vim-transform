# Dev Status
VERY Experimental for my personal use.

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

```vim
let g:transform = {}
function! g:transform._(e)
  return "_" . "/stringfy_word.rb"
endfunction

function! g:transform.go(e)
  let c = a:e.content
  let f = ''
  if c.line_s =~# '\v^const\s*\('
    let f = "go/const_stringfy.rb"
  elseif c['line_s-1'] =~# '\v^import\s*\('
    let f = "go/import.rb"
  endif
  return f
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

# TODO?
* `:'<,'>!` is always linewise, you can't transform partial area within single line.
* good default config and tranformer set
* template engine like erb is better in most case?
* Whats' defference in advanced snipett plugin?(maybe this is way simple).
* Make multiple tranformer chainable so that we can  stringfy then surround by `import(` and `)`.
* chosing appropriate transformer is hard, better to `do_what_I_mean` behavior by invoking controller and controller choose appropriate transformer from context(language and passed string).
* Transformer Specification? when first arg is 'check', it shoud return 1 or 0 which is used by controller to determine appropreate transformer.
* CofferScript will be great helper as transformer for its simple syntax to JavaScript syntax(some of which is legal in other language).
