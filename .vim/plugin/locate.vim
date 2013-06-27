" File: locate.vim
" Author: Richard Hull (rm_hull AT yahoo DOT co DOT uk)
" Version: 0.2
" Last Modified: May 31, 2012
"
" Overview
" --------
" The locate plugin integrates the locate tools with Vim, allowing
" you to search across a filesystem for matching files, and jump to
" them.
"
" Shamelessly ripped off from:
"    http://www.vim.org/scripts/script.php?script_id=311
"
" History
" -------
" 0.1   May 03, 2012  Initial version
" 0.2   May 31, 2012  Close any existing location windows first
" 
" --------------------- Do not modify after this line ---------------------
if exists("loaded_locate")
    finish
endif
let loaded_locate = 1

" Line continuation used here
let s:cpo_save = &cpo
set cpo&vim


" Location of the locate utility
if !exists("Locate_Path")
    let Locate_Path = 'locate'
endif

" Default locate options
if !exists("Locate_Default_Options")
    let Locate_Default_Options = ''
endif


" Character to use to quote patterns and filenames before passing to locate.
if !exists("Locate_Shell_Quote_Char")
    if has("win32") || has("win16") || has("win95")
        let Locate_Shell_Quote_Char = ''
    else
        let Locate_Shell_Quote_Char = "'"
    endif
endif

" Character to use to escape special characters before passing to Locate.
if !exists("Locate_Shell_Escape_Char")
    if has("win32") || has("win16") || has("win95")
        let Locate_Shell_Escape_Char = ''
    else
        let Locate_Shell_Escape_Char = '\'
    endif
endif

" RunLocateCmd()
" Run the specified locate command using the supplied pattern
function! s:RunLocateCmd(cmd, pattern, action)
    let cmd_output = system(a:cmd)

    if cmd_output == ""
        echohl WarningMsg | 
        \ echomsg "Error: Pattern " . a:pattern . " not found" | 
        \ echohl None
        return
    endif

    let tmpfile = tempname()

    let old_verbose = &verbose
    set verbose&vim

    exe "redir! > " . tmpfile
    silent echon cmd_output
    redir END

    let &verbose = old_verbose

    let old_efm = &efm
    set efm=%f

    if v:version >= 700 && a:action == 'add'
        execute "silent! laddfile " . tmpfile
    else
        if exists(":lgetfile")
            execute "silent! lgetfile " . tmpfile
        else
            execute "silent! lfile " . tmpfile
        endif
    endif

    let &efm = old_efm

    " Open the Locate output window (making sure to close any existing)
    lclose
    botright lopen

    call delete(tmpfile)
endfunction

" RunLocate()
" Run the specified locate command
function! s:RunLocate(cmd_name, locate_cmd, action, ...)
    if a:0 > 0 && (a:1 == "-?" || a:1 == "-h")
        echo 'Usage: ' . a:cmd_name . " [<locate_options>] [<search_pattern> " 
        return
    endif

    let locate_opt  = ""
    let pattern   = ""
    let filenames = ""

    " Parse the arguments
    " locate command-line flags are specified using the "-flag" format
    " the next argument is assumed to be the pattern
    " and the next arguments are assumed to be filenames or file patterns
    let argcnt = 1
    while argcnt <= a:0
        if a:{argcnt} =~ '^-'
            let locate_opt = locate_opt . " " . a:{argcnt}
        elseif pattern == ""
            let pattern = g:Locate_Shell_Quote_Char . a:{argcnt} .
                            \ g:Locate_Shell_Quote_Char
        endif
        let argcnt = argcnt + 1
    endwhile

    let locate_path = g:Locate_Path

    if locate_opt == ""
        let locate_opt = g:Locate_Default_Options
    endif

    " Get the identifier and file list from user
    if pattern == "" 
        let pattern = input("Locate file: ", expand("<cword>"))
        if pattern == ""
            return
        endif
        let pattern = g:Locate_Shell_Quote_Char . pattern .
                        \ g:Locate_Shell_Quote_Char
    endif

    let cmd = locate_path . " " . locate_opt . " " . pattern

    call s:RunLocateCmd(cmd, pattern, a:action)
endfunction

" Define the set of locate commands
command! -nargs=* -complete=file Locate
            \ call s:RunLocate('Locate', 'locate', 'set', <f-args>)

" Add the Tools->Search Files menu
if has('gui_running')
    anoremenu <silent> Tools.Search.File\ Names<Tab>:Locate
                \ :Locate<CR>
endif

" restore 'cpo'
let &cpo = s:cpo_save
unlet s:cpo_save


