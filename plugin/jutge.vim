
"if exists("g:loaded_jutge")
     "Nothing to do
    "finish
"endif

" Get the path of the file being sourced
let s:local_path = expand('<sfile>:p:h')

" Mark as loaded
let g:loaded_jutge = 1

" Initilize defaults if not specified by the user
let g:jutge_command = get(g:,'jutge_command', expand(s:local_path .'/../python/jutgeutils/jutge.py'))

let g:jutge_folder = get(g:, 'jutge_folder' , $HOME . '/Documents/jutge')

let g:jutge_default_flags = get(g:, 'jutge_default_flags' , '')

let g:jutge_done_folder = get(g:, 'jutge_done_folder', g:jutge_folder . '/done')

" Boolean, tells JutgeFet() to delete file in working dir after writing it
" to the done folder
let g:jutge_delete_done = get(g:,'jutge_delete_done', 1)

" Check that jutge.py is installed and working
if !executable(g:jutge_command)
    echoerr "Jutge error: " . g:jutge_command . " not found in PATH or is not executable. Did you forget to run 'git submodule update --init --recursive'?"
endif

" Wraper around jutge.py to test cases from jutge.org
function! JutgeTest(...)
    let s:jutge_flags = join(a:000) . ' ' . g:jutge_default_flags
    if has('nvim')
        exec 'term ' . g:jutge_command . ' test ' . '"%" '. s:jutge_flags 
    else
        exec '!' . g:jutge_command . ' test ' . '"%" '. s:jutge_flags 
    endif
endfunction

function! JutgeDownload(...)
    let s:jutge_flags = join(a:000) . ' ' . g:jutge_default_flags
    exec '!' . g:jutge_command . ' download ' . '"%" ' . s:jutge_flags 
endfunction

function! JutgeAddCases(...)
    let s:jutge_flags = join(a:000) . ' ' . g:jutge_default_flags
    if has('nvim')
        exec 'term ' . g:jutge_command . ' addcases ' . '"%" ' . s:jutge_flags 
    else
        exec '!' . g:jutge_command . ' addcases ' . '"%" ' . s:jutge_flags 
    endif
endfunction

function! JutgeGet(...)
    if a:0 != 1
        echoerr "1 argument needed"
        return
    endif
    if a:1 == 'name'
        exec '!' . g:jutge_command . ' getname ' . '"%"'
    elseif a:1 == 'code' 
        exec '!' . g:jutge_command . ' getcode ' . '"%"'
    elseif a:1 == 'statement'
        if has('nvim')
            exec 'term ' . g:jutge_command . ' getstatement ' . '"%"'
        else
            exec '!' . g:jutge_command . ' getstatement ' . '"%"'
        endif
    elseif a:1 == 'samples'
        if has('nvim')
            exec 'term ' . g:jutge_command . ' getsamples ' . '"%"'
        else
            exec '!' . g:jutge_command . ' getsamples ' . '"%"'
        endif
    else
        echoerr 'Invalid command'
    endif
endfunction

" Move done programms to a specifici folder. Use with care
function! JutgeFet()
    let s:option = confirm("This will move the current file to " . g:jutge_done_folder . " proceed?", "&Yes\n&no", 1)
    if s:option==1
        let s:filename = g:jutge_done_folder . expand('/%')
        if expand('%') == s:filename
            echom "Aborting, current file is in the Done folder"
            return
        endif
        if filereadable(s:filename)
            let s:option = confirm("Overwrite" . s:filename, "&Yes\n&no", 1)
            if s:option == 1
                exec 'write! ' s:filename
            else 
                return
            endif
        else 
            exec 'write ' s:filename
        endif
        if g:jutge_delete_done
            call delete('%')
            bdelete!
        endif
    endif

endfunction

function! JutgeNew()
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
endfunction

" Commands to the previoud functions
command! -nargs=? JutgeTest call JutgeTest(<f-args>)
command! JutgeFet call JutgeFet()
command! -nargs=1 JutgeGet call JutgeGet(<f-args>)
command! JutgeDownload call JutgeDownload()
command! -nargs=? JutgeAddCases call JutgeAddCases(<f-args>)

" If dentie exists define some nice commands to search through already solved
" problems
command! JutgeSearch exec 'Denite -path=' . g:jutge_done_folder ' file_rec'
command! -nargs=? JutgeGrep exec 'Denite -path=' . expand(g:jutge_done_folder) ' grep -input=' . '<args>'
