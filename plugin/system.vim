" Author: Marcin Szamotulski
" Email:  mszamot [AT] gmail [DOT] com
" Licence: vim-licence
"
" This is a tiny vim script which might have been discvered ages ago (but I am
" unaware). Its rather for vim than gvim users.
"
" When executing commands from vim you enter a vim shell where you see the
" output. In many situations this is not what you want and you'd prefere 
" :call system("command")
" but it is a lot to type, and you don't have completion. With this snipet
" every command which start with:
" :! command
" a space after the "!" will be wrapped into system() and the output will be
" echoed.
" The executed command will also be echoed (on the very top).
"
" There is some configuration variables:
" g:system_expand = 1
"         by default % (with modifiers) is expanded in the same way as by the :!.
" g:system_echocmd = 0
"         echo the command (by default no, since the history looks less visible)
" g:system_history = 1
"         add the ':! command' to the history, note that then both commands: 
"         ':! command' and 'echo system("command")' will be in the history
"         (the second will be the last one).
"
"
" Benefits: you get completion for system commanads and system files.

" Copyright: 2012 Marcin Szamotulski

" I learned how to do that reading the emacscommandline plugin.
"
" Happy viming,
"  Marcin Szamotulski

if !exists("g:system_expand")
    let g:system_expand = 1
    " If 1 expand % as in the command line.
endif
if !exists("g:system_echocmd")
    let g:system_echocmd = 0
endif
if !exists("g:system_history")
    let g:system_history = 1
endif

fun! <SID>WrapCmdLine()
    let cmdline = getcmdline()
    " Add cmdline to history
    if g:system_history
	call histadd(":", cmdline)
    endif
    if cmdline[0:1] == "! "  
	let cmd = cmdline[2:]
	if g:system_expand
	    let cmd_split = split(cmd, '\ze\\\@<!%')
	    let cmd = ""
	    for hunk in cmd_split
		if hunk[0] == '%'
		    let m = matchstr(hunk, '^%\%(:[p8~.htre]\|:g\=s?[^?]*?[^?]*?\)*')
		    let exp = expand(m)
		    let cmd .=exp.hunk[len(m):]
		else
		    let cmd .=hunk
		endif
	    endfor
	endif
	let cmd = escape(cmd, "\"")
	if g:system_echocmd
	    return "echo system(\"".cmd."\")"
	else
	    return "echo \"".cmd."\n\".system(\"".cmd."\")"
	endif
    endif
    return cmdline
endfun
cnoremap <silent> <CR> <C-\>e<SID>WrapCmdLine()<CR><CR>
