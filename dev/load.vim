let &runtimepath=resolve(expand("<sfile>:p:h") . "/..") . "," . &runtimepath
lua package.loaded.conjure = nil
source plugin/conjure.vim
edit src/conjure/main.clj
