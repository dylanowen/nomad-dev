call plug#begin('~/.vim/plugged')

   Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
   Plug 'scrooloose/nerdtree'

call plug#end()

""" Configuration
set number                                                        " Add line numbers
" Sets tabs to 3 spaces and uses spaces instead of tabs
set tabstop=3 softtabstop=0 expandtab shiftwidth=0 smarttab
" Change how netrw works with files
let g:netrw_liststyle = 3
let g:netrw_banner = 0
let g:netrw_browse_split = 4
let g:netrw_winsize = 25

set splitbelow                                                    " open split windows below
set splitright                                                    " open vsplit windows to the right


"autocmd vimenter * nerdtree                                       " open NERDTree on startup
autocmd VimEnter NERD_tree_1 enew | execute 'NERDTree '.argv()[0]

" use <tab> for trigger completion and navigate to next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" inoremap <silent><expr> <TAB>
"      \ pumvisible() ? "\<C-n>" :
"      \ <SID>check_back_space() ? "\<TAB>" :
"      \ coc#refresh()<Paste>
