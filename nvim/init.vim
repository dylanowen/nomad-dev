""" Plugins
call plug#begin('~/.vim/plugged')

   Plug 'derekwyatt/vim-scala'
   Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
   Plug 'scrooloose/nerdtree'

call plug#end()





" Configuration for vim-scala
au BufRead,BufNewFile *.sbt set filetype=scala



""" Configuration
set number                                                        " Add line numbers
" Sets tabs to 3 spaces and uses spaces instead of tabs
set tabstop=3 softtabstop=0 expandtab shiftwidth=0 smarttab
" Change how netrw works with files
" let g:netrw_liststyle = 3
" let g:netrw_banner = 0
" let g:netrw_browse_split = 4
" let g:netrw_winsize = 25

set splitbelow                                                    " open split windows below
set splitright                                                    " open vsplit windows to the right


"autocmd vimenter * nerdtree                                       " open NERDTree on startup
autocmd VimEnter NERD_tree_1 enew | execute 'NERDTree '.argv()[0]
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeShowHidden=1

" use <tab> for trigger completion and navigate to next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" :CocInstall coc-rls

" inoremap <silent><expr> <TAB>
"      \ pumvisible() ? "\<C-n>" :
"      \ <SID>check_back_space() ? "\<TAB>" :
"      \ coc#refresh()<Paste>




"set termguicolors 
"colorscheme NeoSolarized




" Configuration for coc.nvim

" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Some server have issues with backup files, see #649
set nobackup
set nowritebackup

" Better display for messages
set cmdheight=2

" Use <c-space> for trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[c` and `]c` for navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Remap for do codeAction of current line
nmap <leader>ac <Plug>(coc-codeaction)

" Remap for do action format
nnoremap <silent> F :call CocAction('format')<CR>

" Use K for show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>






" Enable Alt+{h,j,k,l) to navigate windows in any mode
:tnoremap ˙ <C-\><C-N><C-w>h
:tnoremap ∆ <C-\><C-N><C-w>j
:tnoremap ˚ <C-\><C-N><C-w>k
:tnoremap ¬ <C-\><C-N><C-w>l
:inoremap ˙ <C-\><C-N><C-w>h
:inoremap ∆ <C-\><C-N><C-w>j
:inoremap ˚ <C-\><C-N><C-w>k
:inoremap ¬ <C-\><C-N><C-w>l
:nnoremap ˙ <C-w>h
:nnoremap ∆ <C-w>j
:nnoremap ˚ <C-w>k
:nnoremap ¬ <C-w>l
