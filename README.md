# Dev Status
Experimental for my personal use.

# STDIN => transform => STDOUT

Thats' filter command.
Filter command in other word => transformer.

you can write transformer whichever language you want.  

Using vim's `!` command you can transform selected area by that transformer.  
This have great possibility to reduce typing!  

![Movie](https://raw.githubusercontent.com/t9md/t9md/772e1fe5287a29c01b3bb2418f757aa29785a4f8/img/transform.gif)

# TODO?
* `:'<,'>!` is always linewise, you can't transform partial area within single line.
* Even if transformer raise error, buffer is replaced with that error msg.
* template engine like erb is better in most case?
* Whats' defference in advanced snipett plugin?(maybe this is way simple).
* Make chainable multiple tranformer like stringfy selected area then surround by `import(` and `)`.
* chosing appropriate transformer is hard, better to `do_what_I_mean` behavior by invoking controller and controller choose appropriate transformer from context(language and passed string).
* Transformer Specification? when first arg is 'check', it shoud return 1 or 0 which is used by controller to determine appropreate transformer.
* CofferScript will be great helper as transformer for its simple syntax to JavaScript syntax(some of which is legal in other language).
