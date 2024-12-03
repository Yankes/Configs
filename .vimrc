
syntax on
language C

set smartindent
set tabstop=4
set shiftwidth=4
set ffs=unix

set backspace=start
set nowrap
set nu
set noerrorbells visualbell t_vb=
set encoding=utf-8
set relativenumber
set number
set list

hi NonText ctermfg=darkgray
hi SpecialKey ctermfg=darkgray
hi LineNr ctermfg=gray
hi CursorLineNr ctermfg=yellow
hi diffRemoved ctermfg=Red

let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_SR.="\e[3 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"

if &diff
    " diff mode
    set diffopt+=iwhite
endif

command YamlStyle execute ":set ts=2 sw=2 et smartindent"
command PurgeDos execute ":%s/\\s*\r//e"
command FindConflict execute "/^\\(<<<<<<<\\||||||||\\|=======\\|>>>>>>>\\)"

function SetStyle()
    syn match myConstant '^<<<<<<<.*'
    syn match myConstant '^=======.*'
    syn match myConstant '^|||||||.*'
    syn match myConstant '^>>>>>>>.*'
    hi kwRed ctermfg=cyan
    hi def link myConstant kwRed
endfunction

au FileType * call SetStyle()

inoremap <C-Space> <C-N>

inoremap <S-Tab> <C-d>
vmap <Tab> >
vmap <S-Tab> <
