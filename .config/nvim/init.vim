" Plugins
call plug#begin(stdpath('data') . '/plugged')

" Wakatime stats
Plug 'wakatime/vim-wakatime'

" Python Formatter
Plug 'psf/black'

" GRUVBOX
Plug 'morhetz/gruvbox'

" Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" CoC
" Plug 'neoclide/coc.nvim', {'branch': 'release'} " Release
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'} " From Source

" vim in Firefox
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }

call plug#end()

" ---------- Basic Remaps -----------
let mapleader = ","

" ---------- CoC Settings -----------

" Remap for do codeAction of selected region for coc-actions
function! s:cocActionsOpenFromSelected(type) abort
  execute 'CocCommand actions.open ' . a:type
endfunction
xmap <silent> <leader>a :<C-u>execute 'CocCommand actions.open ' . visualmode()<CR>
nmap <silent> <leader>a :<C-u>set operatorfunc=<SID>cocActionsOpenFromSelected<CR>g@


" Set completion to c-space
inoremap <silent><expr> <c-space> coc#refresh()

" Navagate suggestion list with tab
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Auto format & add missing import on save for Go
autocmd BufWritePre *.go :call CocAction('runCommand', 'editor.action.organizeImport')

" Alias ToDo commands
command Td CocList todolist
command TdNew CocCommand todolist.create

" Fix Spelling Errors
nmap <leader>s <Plug>(coc-codeaction-selected)

" Python Path
let g:python3_host_prog = '~/.config/nvim/.venv/bin/python'


" ---------- Theme ----------
let g:gruvbox_italic=1
set termguicolors
colorscheme gruvbox


" Status Bar
let g:airline_theme='gruvbox'
let laststatus=2 " Always on

" Python Highlighting
let python_highlight_all=1
syntax on


" Line numbering
set number
set relativenumber

" Indents
set tabstop=4
set shiftwidth=4
