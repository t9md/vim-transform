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

# Ideally
don't want to editor independent.

# Need to consider
* command line arguments(or parameters) to transformer?
* Unite transformer

# Done
* Making excutable each transformer eliminate consideration by which programming ranguage transformer is written.
* determine appropreate run command like 'ruby', 'python', 'go run' from extention of each transfomer?

# TODO?
* choose appropriate set of transformer from `&filetype`
* laod user's transformer
* `:'<,'>!` is always linewise, you can't transform partial area within single line.
* Even if transformer raise error, buffer is replaced with that error msg.
* template engine like erb is better in most case?
* Whats' defference in advanced snipett plugin?(maybe this is way simple).
* Make multiple tranformer chainable so that we can  stringfy then surround by `import(` and `)`.
* chosing appropriate transformer is hard, better to `do_what_I_mean` behavior by invoking controller and controller choose appropriate transformer from context(language and passed string).
* Transformer Specification? when first arg is 'check', it shoud return 1 or 0 which is used by controller to determine appropreate transformer.
* CofferScript will be great helper as transformer for its simple syntax to JavaScript syntax(some of which is legal in other language).
