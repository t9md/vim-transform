let s:_ = {}

function s:_.surround(...)
  let [before, after; other ] = a:000
  let R = join([before, self.env.content.res, after], " ")
  let self.env.content.res = R
endfunction

function! transform#helper#get()
  return s:_
endfunction
