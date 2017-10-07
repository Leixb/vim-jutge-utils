
if exists("g:loaded_jutge")
    "Nothing to do
    finish
endif

" Get the path of the file being sourced
let s:local_path = expand('<sfile>:p:h')

" Mark as loaded
let g:loaded_jutge = 1

" Jutge cookie
let g:jutge_cookie = ""

" Initilize defaults if not specified by the user
let g:jutge_command = get(g:,'jutge_command', expand(s:local_path .'/../python/jutge_cli/jutge.py'))
let g:jutge_command_cookie = g:jutge_command

let g:jutge_folder = get(g:, 'jutge_folder' , $HOME . '/Documents/UPC/jutge')

let g:jutge_default_flags = get(g:, 'jutge_default_flags' , '')
let g:jutge_test_flags = get(g:, 'jutge_test_flags' , '')
let g:jutge_download_flags = get(g:, 'jutge_download_flags' , '')
let g:jutge_addtest_flags = get(g:, 'jutge_addtest_flags' , '')

let g:jutge_done_folder = get(g:, 'jutge_done_folder', g:jutge_folder . '/Done')

" Boolean, tells JutgeArchive() to delete file in working dir after writing it
" to the archive
let g:jutge_delete_done = get(g:,'jutge_delete_done', 1)

" Check that jutge.py is installed and working
if !executable(g:jutge_command)
    echoerr "Jutge error: " . g:jutge_command . " not found in PATH or is not executable. Did you forget to run 'git submodule update --init --recursive'?"
endif

function! JutgeVimCookie(...) abort
    if a:0 == 0
        let s:clipboard_content = @+
        if s:clipboard_content == "" 
            echoerr "Clipboard empty!"
            return
        else
            let g:jutge_cookie = s:clipboard_content
        endif
    else
        if a:0 == "" 
            echoerr "No cookie provided and Clipboard is empty!"
            return
        else
            let g:jutge_cookie = a:0
        endif
    endif

    let g:jutge_command_cookie = g:jutge_command . ' --cookie ' . g:jutge_cookie

    echomsg g:jutge_cookie
endfunction

" Wraper around jutge.py to test cases from jutge.org
function! JutgeTest(...) abort
    let s:jutge_flags = join(a:000) . ' ' . g:jutge_default_flags . ' ' . g:jutge_test_flags
    if has('nvim')
        exec 'term ' . g:jutge_command_cookie . ' test "%"' . s:jutge_flags 
    else
        exec '!' . g:jutge_command_cookie . ' test "%"' . s:jutge_flags 
    endif
endfunction

function! JutgeDownload(...) abort
    let s:jutge_flags = join(a:000) . ' ' . g:jutge_default_flags . ' ' . g:jutge_download_flags
    exec '!' . g:jutge_command_cookie . ' download ' . '"%" ' . s:jutge_flags 
endfunction

function! JutgeAddTest(...) abort
    let s:jutge_flags = join(a:000) . ' ' . g:jutge_default_flags . ' ' . g:jutge_addtest_flags
    if has('nvim')
        exec 'term ' . g:jutge_command_cookie . ' add-test ' . '"%" ' . s:jutge_flags 
    else
        exec '!' . g:jutge_command_cookie . ' add-test ' . '"%" ' . s:jutge_flags 
    endif
endfunction

function! JutgeShow(...) abort
    if a:0 != 1
        echoerr "1 argument needed"
        return
    endif
    if a:1 == 'name'
        exec '!' . g:jutge_command_cookie . ' show title ' . '-p "%"'
    elseif a:1 == 'stat'
        if has('nvim')
            exec 'term ' . g:jutge_command_cookie . ' show stat ' . '-p "%"'
        else
            exec '!' . g:jutge_command_cookie . ' show stat ' . '-p "%"'
        endif
    elseif a:1 == 'cases'
        if has('nvim')
            exec 'term ' . g:jutge_command_cookie . ' show cases ' . '-p "%"'
        else
            exec '!' . g:jutge_command_cookie . ' show cases ' . '-p "%"'
        endif
    else
        echoerr 'Invalid command'
    endif
endfunction

" Move done programms to a specifici folder. Use with care

function! JutgeArchive() abort
    let s:option = confirm("This will move the current file to the archive; proceed?", "&Yes\n&no", 1)
    if s:option==1
        if g:jutge_delete_done==1
            let s:filename = expand("%")
            bd!
            exec '!' . g:jutge_command_cookie . ' archive "' . s:filename . '"'
        else
            exec '!' . g:jutge_command_cookie . ' archive "%" --no-delete'
        endif
    endif
endfunction

function! JutgeNew() abort
    let s:jutge_flags = join(a:000) . ' ' . g:jutge_default_flags . ' ' . g:jutge_new_flags
    if a:0 == 0
        let s:name = @+
        if s:name == "" 
            echoerr "Clipboard empty"
            return
        endif
    elseif a:0 == 1
        s:name = a:0
    else
        echoerr "This function takes one parameter or the name from the clipboard"
        return
    endif
    echomsg s:name
    exec '!' . g:jutge_command_cookie . ' new ' . s:name . ' ' .s:jutge_flags
endfunction

function! JutgeCookie() abort
    if a:0 == 0
        let s:name = @+
        if s:name == "" 
            echoerr "Clipboard empty"
            return
        endif
    elseif a:0 == 1
        s:name = a:0
    else
        echoerr "This function takes one parameter or the name from the clipboard"
        return
    endif
    echomsg s:name
    exec '!' . g:jutge_command . ' cookie ' . s:name
endfunction

function! JutgeUpload() abort
    let s:jutge_flags = join(a:000) . ' ' . g:jutge_default_flags . ' ' . g:jutge_new_flags
    exec '!' . g:jutge_command_cookie . ' upload "%"'
endfunction

function! JutgeUploadAndCheck() abort
    exec '!' . g:jutge_command_cookie . ' upload "%" --check'
endfunction

function! JutgeCheck() abort
    exec '!' . g:jutge_command_cookie . ' check --last'
endfunction

function! JutgeLogin() abort
    exec '!' . g:jutge_command . ' login'
endfunction

" Commands to the previoud functions
command! -nargs=? JTest call JutgeTest(<f-args>)
command! JArchive call JutgeArchive()
command! -nargs=1 JShow call JutgeShow(<f-args>)
command! JDownload call JutgeDownload()
command! -nargs=? JAddTest call JutgeAddTest(<f-args>)
command! -nargs=? JCookie call JutgeCookie(<f-args>)
command! -nargs=? JVimCookie call JutgeVimCookie(<f-args>)
command! -nargs=? JNew call JutgeNew(<f-args>)
command! JUpload call JutgeUpload()
command! JCheck call JutgeCheck()
command! JLogin call JutgeLogin()

" If dentie exists define some nice commands to search through already solved
" problems
command! JSearch exec 'Denite -path=' . expand(g:jutge_done_folder) ' file_rec'
command! -nargs=? JGrep exec 'Denite -path=' . expand(g:jutge_done_folder) . ' grep -input=' . '<args>'
