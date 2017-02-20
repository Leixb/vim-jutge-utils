
if exists("g:loaded_jutge")
    " Nothing to do
    finish
endif

" Get the path of the file being sourced
let s:local_path = expand('<sfile>:p:h')

" Mark as loaded
let g:loaded_jutge = 1

" Initilize defaults if not specified by the user
let g:jutge_testj = get(g:,'jutge_testj', expand(s:local_path .'/../python/jutgeutils/testj.py'))

let g:jutge_folder = get(g:, 'jutge_folder' , $HOME . '/Documents/jutge')

let g:jutge_done_folder = get(g:, 'jutge_done_folder', g:jutge_folder . '/done')

" Boolean, tells JutgeFet() to delete file in working dir after writing it
" to the done folder
let g:jutge_delete_done = get(g:,'jutge_delete_done', 1)

" Check that testj is installed and working
if !executable(g:jutge_testj)
    echoerr "Jutge error: " . g:jutge_testj . " not found in PATH or is not executable. Did you forget to run 'git submodule update --init --recursive'?"
endif

" Wraper around testj.py to test cases from jutge.org
function! JutgeTest(...)
    let s:jutge_flags = join(a:000)
    if has('nvim')
        exec 'term ' . g:jutge_testj . ' ' . s:jutge_flags . '"%"'
    else
        exec '!' . g:jutge_testj . ' ' . s:jutge_flags . '"%"'
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

" Commands to the previoud functions
command! -nargs=? JutgeTest call JutgeTest(<f-args>)
command! JutgeFet call JutgeFet()

" If dentie exists define some nice commands to search through already solved
" problems
command! JutgeSearch exec 'Denite -path=' . g:jutge_done_folder ' file_rec'
command! -nargs=? JutgeGrep exec 'Denite -path=' . expand(g:jutge_done_folder) ' grep -input=' . '<args>'
