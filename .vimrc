" .vimrc (Version 7) file
"
" Richard Hull 17/06/2012
"
" vim:set ts=4 sw=4:

execute pathogen#infect()
execute pathogen#helptags()

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible
source $VIMRUNTIME/syntax/syntax.vim

set term=builtin_ansi
set wildmenu
set ttyfast

set backupdir=~/.vim/swaps
set directory=~/.vim/backups
if exists("&undodir")
    set undofile
    set undodir=~/.vim/undo
endif

syntax on                   " syntax highlighting
"set autochdir              " always switch to the current file directory.. Messes with some plugins, best left commented out
scriptencoding utf-8
set encoding=utf-8 nobomb
set binary
set noeol
set modeline
set modelines=4
set lcs=tab:▸\ ,trail:·,nbsp:_
set list

" set autowrite                  " automatically write a file when leaving a modified buffer
set shortmess+=filmnrxoOtT      " abbrev. of messages (avoids 'hit enter')
set viewoptions=folds,options,cursor,unix,slash " better unix / windows compatibility
set virtualedit=onemore         " allow for cursor beyond last character
set history=1000                " Store a ton of history (default is 20)
"set spell                       " spell checking on
"setlocal spell spelllang=en_gb
set nu
set selectmode=mouse
set fileformat=unix     " Zap any ^M characters
set autowrite           " write file on :next, :make, :tag, etc.
set autoread            " automatically re-read if changed outside vim
set nowrapscan          " Search does NOT wrap around at the end of the file
set showmatch           " shows matching brackets
set hlsearch
set ignorecase          " ignore case in search patterns
set smartcase           " case sensitive when uc present
set backspace=2         " allow backspacing over everything in insert mode
set expandtab           " Tabs automatically expanded to spaces
set autoindent          " always set autoindenting on
set viminfo='20,\"50    " read/write a .viminfo file, don't
                        " store more than 50 lines of registers
set laststatus=2        " always display a status line at the bottom of window
set ruler               " display the current line and col at all times
set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " a ruler on steroids
set mouse=a
set tabstop=4           " default tabstop of 8 spaces
set shiftwidth=4        " default shiftwidth of 4 spaces
set softtabstop=4
set tildeop             " allow tilde (~) to act as an operator -- ~w, etc.
set showcmd             " display incomplete commands
set tags=tags;./.git/tags;/

set wildignore=*.o,*.class,~*,*.swp,*/.git/*,*/.svn/*,*/target/*
set wildmode=list:longest,full  " command <Tab> completion, list matches, then longest common part, then all.
set whichwrap=b,s,h,l,<,>,[,]   " backspace and cursor keys wrap to
set foldenable                  " auto fold code

set gdefault                    " the /g flag on :s substitutions by default

map  g]
map Q gq                " Don't use Ex mode, use Q for formatting
vnoremap < <gv          " Outdent by shiftwidth mapped to '<' key
vnoremap > >gv          " Indent by shiftwidth mapped to '>' key
vmap <tab> >gv          " make tab in v mode work like I think it should
vmap <s-tab> <gv
if has('statusline')
    set laststatus=2
    "set statusline=[%02n]\ %t\ %(\[%M%R%H]%)%=\ %4l,%02c%2V\ %P%*

    " Broken down into easily includeable segments
    set statusline=%<\:b%n\ %f\   " Filename
    set statusline+=%w%h%m%r " Options
    set statusline+=%{fugitive#statusline()} "  Git Hotness
    set statusline+=\ [%{&ff}/%Y]            " filetype
    set statusline+=\ [%{getcwd()}]          " current dir
    "set statusline+=\ [A=\%03.3b/H=\%02.2B] " ASCII / Hexadecimal value of char
    "set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
    set statusline+=%=\ %4l,%02c%2V\ %P%* " a ruler on steroids
endif
set nowrap              " don't wrap lines at the edge of the screen
command -nargs=* Make make <args> | cwindow
botright cwindow
nnoremap <silent> <F8> :Tlist<cr>
map <F12> :Make<cr>
map <S-F11> :set wrap!<cr>
let tlist_javascript_settings = 'javascript;r:var;s:string;a:array;o:object;u:function'
let tlist_groovy_settings = 'groovy;c:class;f:method;p:property;v:private variables;x:variables;u:public variables'
let tlist_clojure_settings = 'clojure;n:namespace;d:definition;c:definition (once);s:struct;f:function;p:protocol;m:macro;i:inline;a:multimethod definition;b:multimethod instance;v:intern;t:test;r:record'
let tlist_haskell_settings = 'haskell;t:type;c:constructor;f:function;m:module'
let Tlist_Sort_Type = "name"
let tlist_show_one_file = 1
" Word completion
"set dictionary-=/usr/share/dict/words dictionary+=/usr/share/dict/words
set complete-=k complete+=k

let showmarks_include = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
let g:showmarks_enable = 1
" For marks a-z
highlight ShowMarksHLl gui=bold guibg=LightBlue guifg=Blue
" For marks A-Z
highlight ShowMarksHLu gui=bold guibg=LightRed guifg=DarkRed
" For all other marks
highlight ShowMarksHLo gui=bold guibg=LightYellow guifg=DarkYellow
" For multiple marks on the same line.
highlight ShowMarksHLm gui=bold guibg=LightGreen guifg=DarkGreen

" JSON 
nmap <leader>jt <Esc>:%!python -m json.tool<CR><Esc>:set filetype=json<CR>

" Date/Time stamps
iab xstamp  <C-R>=strftime("%a %b %d %H:%M:%S %Y")<CR>
iab lastmod  <C-R>="Last Modified: " . strftime("%a %b %d %H:%M:%S %Y")<CR>

au Filetype html setlocal sw=2 ts=2 sts=2
au Filetype less setlocal sw=2 ts=2 sts=2
au Filetype css setlocal sw=2 ts=2 sts=2
au Filetype sass setlocal sw=2 ts=2 sts=2

autocmd BufRead,BufNewFile *.json setfiletype json syntax=javascript

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufRead *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

" Java files
autocmd FileType java,groovy
    \ set tags+=/export/home/rhu/java-src/tags |
    \ set complete=t cindent sm formatoptions=croql |
    \ set foldenable foldmethod=marker foldcolumn=2 |
    \ set comments=s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:- |
    \ set efm+=%f:%l:%v:%*\\d:%*\\d:%*\\s%m |
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif |
    \ map <S-F12> :s#.* \([^ ][^ ]*\)  *\([^ ][^ ]*\);#    public \1 get\u\2() {<C-v><CR>        return \2;<C-v><CR>    }<C-v><CR><C-v><CR>    public void set\u\2(\1 \2) {<C-v><CR>        this.\2 = \2;<C-v><CR>    }<C-v><CR><ESC>#<CR><ESC>+:<ESC> |
    \ iab }// } //}}} END: <esc>10h%$?\w\+\s*(<cr>"xy/\s*(<cr>/{<cr>:nohl<cr>%$"xpa

" C/C++ files
autocmd BufNewFile,BufRead *.c,*.h,*.cpp,*.c++,*.pc
    \ set cindent sm formatoptions=croql |
    \ set foldenable foldmethod=marker foldcolumn=2 |
    \ set comments=s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:- |
    \ set efm+=%f:%l:\ %m,In\ file\ included\ from\ %f:%l:,\^I\^Ifrom\ %f:%l%m |
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

"" Perl files
autocmd FileType perl
    \ set cindent sm formatoptions=croql |
    \ set foldenable foldmethod=marker foldcolumn=2 |
    \ set comments=s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:- |
    \ set makeprg=perl\ -wc\ % |
    \ set efm+=%m\ at\ %f\ line\ %l%.%#,
                    \%-G%.%# |
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

" Ruby files
autocmd FileType ruby,eruby,javascript,coffeescript
    \ set tabstop=2 shiftwidth=2 softtabstop=2 |
    \ set formatoptions=croql smartindent
"    \ set foldenable foldmethod=syntax foldcolumn=2 foldnestmax=2 |

" Scala files
autocmd FileType scala
    \ set ts=2 tags+=/home/richard.hull/tools/scala-2.9.1.final/src/tags |
    \ set complete+=t cindent sm formatoptions=croql |
    \ set foldenable foldmethod=marker foldcolumn=2 |
    \ set comments=s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:- |
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

" Makrdown files
au BufRead,BufNewFile *.md set filetype=markdown

" Are we starting VIM in a maven-aware directory?
if filereadable("pom.xml")
  exec "set makeprg=mvn"
  set efm=%E[ERROR]\ %f:%l:\ error\:\ %m,%Z,%W[WARNING]\ %f:%l:\ warning\:\ %m,%Z
endif

" Only do this part when compiled with support for autocommands.
" Enable file type detection.
filetype plugin indent on
autocmd FileType text setlocal textwidth=78

:let Grep_Default_Options = '-i'
:let Grep_Skip_Dirs = 'target'
:let Grep_Skip_Files = '*~ *.bak *.class *.war *.jar *.swp'
nnoremap <silent> <F3> :Rfgrep<CR>

:let Locate_Default_Options = '-i -n 50'
nnoremap <silent> <F4> :Locate<CR>

" I can type :help on my own, thanks.
noremap <F1> <Esc>

" Git commit/diff
autocmd FileType gitcommit DiffGitCached | wincmd p

" All other files
autocmd BufRead * set formatoptions=tcql nocindent comments&

set scrolloff=2
set sidescrolloff=10
set sidescroll=1

" Forgot to sudo when opening a file
cnoremap w!! w !sudo dd of=%

" find merge conflict markers
nmap <silent> <leader>cf <ESC>/\v^[<=>]{7}( .*\|$)<CR>

" Making it so ; works like : for commands. Saves typing and eliminates :W style typos due to lazy holding shift.
nnoremap ; :

" Easier moving in tabs and windows
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_
map <C-L> <C-W>l<C-W>_
map <C-H> <C-W>h<C-W>_
map <C-K> <C-W>k<C-W>_

" Wrapped lines goes down/up to next row, rather than next line in file.
nnoremap j gj
nnoremap k gk

" The following two lines conflict with moving to top and bottom of the
" screen
" If you prefer that functionality, comment them out.
map <S-H> gT
map <S-L> gt

" Yank from the cursor to the end of the line, to be consistent with C and D.
nnoremap Y y$

" Reselect visual block after indent/outdent
vnoremap < <gv
vnoremap > >gv

"clearing highlighted search
nmap <silent> <leader>/ :nohlsearch<CR>

" Shortcuts
" Change Working Directory to that of the current file
cmap cwd lcd %:p:h
cmap cd. lcd %:p:h

" visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

" All other files
autocmd BufRead * set formatoptions=tcql nocindent comments&

" Remove trailing whitespaces and ^M chars
autocmd FileType lua,coffeescript,markdown,sql,c,cpp,java,php,haskell,javascript,js,python,twig,xml,json,yml,scala,clojure,clojurescript,groovy autocmd BufWritePre <buffer> :%s/\s\+$//e

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:clojure_align_multiline_strings = 1
let g:syntastic_javascript_checkers = ["jsxhint"]
let g:syntastic_json_checkers = ["jsonlint"]
let g:syntastic_css_checkers = ["csslint"]
let g:jsx_ext_required = 0

let g:vim_markdown_folding_disabled = 1

let hs_highlight_delimiters = 1
let hs_highlight_boolean = 1
let hs_highlight_types = 1
let hs_highlight_more_types = 1

set runtimepath^=~/.vim/bundle/ctrlp.vim
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files --exclude-standard']

let g:indentLine_enabled = 0

:inoremap <A-l> <C-v>u3bb<Space>
autocmd BufRead,BufNewFile *.ylx setlocal filetype=scheme
autocmd BufRead,BufNewFile *.asm set filetype=nasm
autocmd BufRead,BufNewFile *.fth set filetype=forth

if executable('ag')
  let g:ackprg = 'ag --nogroup --nocolor --column'
endif

set nocursorcolumn
syntax sync minlines=128
set ttyfast
set lazyredraw

let g:no_drchip_menu = 1
let g:pymode_python = 'python3'

highlight LineNr ctermfg=darkgrey
highlight LineNr guifg=lightgrey
