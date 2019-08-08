if exists('g:loaded_cljdocs') || &cp
  finish
endif

let g:loaded_cljdocs = 1

function! cljdocs#clojure_doc(sym) abort
  let sym = split(a:sym, '/')[1]
  let ns = split(a:sym, '/')[0]
  let results = system("curl -s https://clojuredocs.org/clojuredocs-export.json | jq '.vars[] | select(.name == \"".sym."\" and .ns == \"".ns."\" ) | {doc,examples}' | jq '.doc,.examples[]?.body'")
  let command = expand('%b') =~ '__CljDocs' ? 'e' : 'split'
  let output = []

  let doc = split(results, '\n')[0]
  let lines = split(results, '\n')[1:-1]

  for line in split(doc, '\n')
    let line = substitute(line, '^"', '', '')
    let line = substitute(line, '"$', '', '')
    let embedded_lines = split(line, '\\n')
    for l in embedded_lines
      let output = output + [";;; " . trim(l)]
    endfor
  endfor

  for line in lines
    let line = substitute(line, '^"', '', '')
    let line = substitute(line, '"$', '', '')
    let embedded_lines = split(line, '\\n')
    for l in embedded_lines
      let output = output + [l]
    endfor
  endfor
  execute command '__CljDocs'.ns.'/'.sym
    setlocal filetype=clojure
    setlocal buftype=nofile
  call append(0, output)
  normal! gg
  nnoremap <buffer> <ESC> :q<CR>
endfunction

autocmd filetype * command! -nargs=1 -buffer ClojureDocs :call cljdocs#clojure_doc(<q-args>)
