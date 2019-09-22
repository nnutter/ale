" Author: Nathaniel Nutter <iam@nnutter.com>
" Description: errcheck for Go files

call ale#Set('go_errcheck_options', '')

function! ale_linters#go#errcheck#GetCommand(buffer) abort
    let l:filename = expand('#' . a:buffer . ':t')
    let l:options = ale#Var(a:buffer, 'go_errcheck_options')

    " BufferCdString is used so that we can be sure the paths output from
    " errcheck can be calculated to absolute paths in the Handler
    let l:command = ale#path#BufferCdString(a:buffer)
    \   . '%e'
    \   . (!empty(l:options) ? ' ' . l:options : '')
    \   . ' ' . ale#Escape(l:filename)
    return l:command
endfunction

function! ale_linters#go#errcheck#Handler(buffer, lines) abort
    " file.go:16:11:	db.reload()
    let l:pattern = '\v^([^:]+):(\d+):(\d+):[\s\t]*(.+)$'
    let l:output = []
    let l:dir = expand('#' . a:buffer . ':p:h')

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:filename = ale#path#GetAbsPath(l:dir, l:match[1])
        call add(l:output, {
        \   'filename': l:filename,
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'text': 'unchecked error on ' . l:match[4],
        \   'type': 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('go', {
\   'name': 'errcheck',
\   'executable': 'errcheck',
\   'command': function('ale_linters#go#errcheck#GetCommand'),
\   'callback': 'ale_linters#go#errcheck#Handler',
\   'output_stream': 'both',
\   'lint_file': 1,
\})
