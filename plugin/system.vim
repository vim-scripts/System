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
" every command which starts with:
" :! command
" (note the space after the "!") will be wrapped into system() and the output will be
" echoed. The plugin refreshes the histry with what you typed rather than the
" call to the system() function.
"
" There is some configuration variables:
" g:system_expand = 1
"         by default % (with modifiers) is expanded in the same way as by the :!.
" g:system_echocmd = 1
"         echo the command together with its output
"
" The reason why I like it is that I have different background colors in vim
" (dark) and terminal (light). If I stay inside vim I am not flushed with
" bright colors which is a anoying (and eyes tireing).
"
" Benefits: you get completion for system commanads and system files.
" Copyright: © Marcin Szamotulski, 2012

" I learned how to do that reading the emacscommandline plugin.
"
" Other plugins with shell like functionality:
" vim-addon-async by Marc Weber: https://github.com/MarcWeber/vim-addon-async
" Conque Shell plugin: http://code.google.com/p/conque
" vimproc plugin: http://github.com/Shougo/vimproc/tree/master/doc/vimproc.txt
"
" Happy viming,
"  Marcin Szamotulski

if !exists("g:system_expand")
    let g:system_expand = 1
    " If 1 expand % as in the command line.
endif
if !exists("g:system_echocmd")
    let g:system_echocmd = 1
endif

fun! <SID>WrapCmdLine()
    let cmdline = getcmdline()
    " Add cmdline to history
    if cmdline[0:1] == "! "  
	let cmd = cmdline[2:]
	call histadd(":", cmdline)
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
	let his = "|call histdel(':', -1)"
	if g:system_echocmd
	    return "echo \"".cmd."\n\".system(\"".cmd."\")".his
	else
	    return "echo system(\"".cmd."\")".his
	endif
    endif
    return cmdline
endfun
cnoremap <silent> <CR> <C-\>e<SID>WrapCmdLine()<CR><CR>
