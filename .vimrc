" .vimrc
" Thibault

set nocompatible

"___________________________
" Vundle :
filetype off
set rtp+=~/.vim/vundle/Vundle.vim
call vundle#begin('~/.vim/vundle')
Plugin 'VundleVim/Vundle.vim'
Plugin 'psf/black'
Plugin 'dense-analysis/ale'
Plugin 'posva/vim-vue'
Plugin 'airblade/vim-gitgutter'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required


"____________________________
" aspect
syntax enable
set vb
set ruler
" affiches les paires de () [] {}
set showmatch

" max number of tab before collapsing to split tab
set tabpagemax=20

"____________________________
" options indentations
set autoindent
"set smartindent

set tabstop=2
set shiftwidth=2

" prog
autocmd BufNewfile,BufRead {SConstruct,SConscript,*.{c,cc,cpp,h,hpp,html,htm,php,css,lisp,py,pl,ml,sh,js,vhd,xml}} set expandtab | set shiftwidth=2
autocmd BufNewfile,BufRead {SConstruct,SConscript,*.{md}} set expandtab | set tabstop=4 | set shiftwidth=4
autocmd BufNewfile,BufRead Makefile set noexpandtab
autocmd BufNewfile,Bufread *.php let php_sql_query=1 | let php_baselib=1 | let php_htmlInStrings=1 | let php_parent_error_close=1 | let php_parent_error_open=1
autocmd BufNewfile,BufRead {SConstruct,SConscript,*.{py}} cnoreab wc w<CR>:!python3 -m py_compile %
autocmd BufNewfile,BufRead {SConstruct,SConscript,*.{rs}} cnoreab wc w<CR>:!cargo build | cnoreab wr w<CR>:!cargo run
autocmd BufNewfile,BufRead {SConstruct,SConscript,*.{tex}} cnoreab wc w<CR>:!pdflatex -interaction=nonstopmode % | cnoreab rr <CR>:! rm *.aux *.log *.out *.synctex.gz *.bbl *.blg *.dvi >/dev/null 2>&1 <CR> | nmap <C-d> di{| imap <C-d> <ESC>di{i| imap <UP> <ESC>gki| imap <DOWN> <ESC>gji

"____________________________
" recherches
set showmatch

set incsearch
set hlsearch
set ignorecase

"____________________________
" folds
set foldmethod=indent
set foldlevel=12

"____________________________
" miscs
set history=50
set mouse=r
set fenc=utf-8

"____________________________
" completion
set wildmode=list:longest

"____________________________
" Terminal magic
if &term =~ "linux"
else
  if has ("terminfo")
    set t_Co=16
    set t_Sf=[3%dm
    set t_Sb=[4%dm
  else
    set t_Co=16
    set t_Sf=[3%
    set t_Sb=[4%
  endif
endif

"____________________________
" key mappings

nmap <F2> :split<CR>
nmap <F3> :vsplit<CR>
imap <F2> <ESC>:split<CR>i
imap <F3> <ESC>:vsplit<CR>i

nmap <C-RIGHT> :tabnext<CR>
nmap <C-LEFT> :tabprevious<CR>
imap <C-RIGHT> <ESC>:tabnext<CR>i
imap <C-LEFT> <ESC>:tabprevious<CR>i

nmap <C-UP> :m-2<CR>
nmap <C-DOWN> :m+1<CR>
imap <C-UP> <ESC>:m-2<CR>i
imap <C-DOWN> <ESC>:m+1<CR>i

map <A-UP> <C-w><UP>
map <A-DOWN> <C-w><DOWN>
map <A-LEFT> <C-w><LEFT>
map <A-RIGHT> <C-w><RIGHT>

nnoremap <Space> :tabnew<CR>
noremap <silent> <F4> :TlistToggle<CR>
nmap ds daw
map <F5> <ESC>:!git grep <C-r><C-w><CR>

map <C-n> :NERDTreeToggle<CR>
"____________________________
" omni completion

filetype plugin on
set ofu=syntaxcomplete#Complete

let Tlist_GainFocus_On_ToggleOpen = 1

"____________________________
" default colorscheme
colorscheme wombat

highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" NDJD : Nooo it's not a virus... at least I hope it's not.
call pathogen#infect()

let g:indentLine_faster = 1
let g:tex_conceal = ""

"Lightline statusline config
set laststatus=2
set noshowmode
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ }

set conceallevel=0

"____________________________
"ALE :
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['eslint'],
\   'python': ['isort','black'],
\}
let g:ale_python_flake8_options = '--max-line-length=88'
