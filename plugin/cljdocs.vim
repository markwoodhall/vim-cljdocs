if exists('g:loaded_cljdocs') || &cp
  finish
endif

let g:loaded_cljdocs = 1

function! cljdocs#clojure_doc(sym) abort
  let parts = split(a:sym, '/')
  let sym = parts[1]
  let ns = parts[0]
  let results = system("curl -s https://clojuredocs.org/clojuredocs-export.json | jq '.vars[] | select(.name == \"".sym."\" and .ns == \"".ns."\" ) | {doc,examples}' | jq '.doc,.examples[]?.body'")
  let output = []

  let lines = split(results, '\n')
  let doc = lines[0]
  let examples = lines[1:-1]

  for line in split(doc, '\n')
    let line = substitute(line, '^"', '', '')
    let line = substitute(line, '"$', '', '')
    let embedded_lines = split(line, '\\n')

    for l in embedded_lines
      let output = output + [";;; " . trim(l)]
    endfor

  endfor

  for line in examples
    let line = substitute(line, '^"', '', '')
    let line = substitute(line, '"$', '', '')
    let embedded_lines = split(line, '\\n')

    for l in embedded_lines
      let output = output + [l]
    endfor

  endfor

  execute 'sp' sym.'.clj'
    call append(0, output)
    setlocal readonly
    normal! gg
    nnoremap <buffer> <ESC> :q!<CR>

endfunction

autocmd filetype * command! -nargs=1 -buffer ClojureDocs :call cljdocs#clojure_doc(<q-args>)
