if exists('g:loaded_cljdocs') || &cp
  finish
endif

let g:loaded_cljdocs = 1

function! s:ClojureDocExamples(ns, sym) abort
  let results = system("curl https://clojuredocs.org/clojuredocs-export.json | jq '.vars[] | select(.name == \"".a:sym."\" and .ns == \"".a:ns."\" ) | {examples}' | jq '.examples[].body'")

  let command = expand('%b') =~ '__CljDocs' ? 'e' : 'split'
  execute command '__CljDocs'.a:ns.'/'.a:sym
    setlocal filetype=clojure
    setlocal buftype=nofile
  call append(0, results)
  normal! gg
  nnoremap <buffer> <ESC> :q<CR>
endfunction

autocmd filetype clojure command! -nargs=2 -buffer ClojureDocs :exe s:ClojureDocExamples(<q-args>)
