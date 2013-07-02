set cursorline
set go=aegimrtT
set guifont=Monospace\ 8
set mousehide         " Hide the mouse when typing text
map <S-Insert> <MiddleMouse> " Make shift-insert work like in Xterm
map! <S-Insert> <MiddleMouse>

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  let java_allow_cpp_keywords=1
  let java_highlight_functions="style"

  "highlight rightMargin term=bold ctermfg=Red guifg=Red gui=bold
  "match rightMargin /.\%>78v/
endif

