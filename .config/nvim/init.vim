" Plugins
call plug#begin(stdpath('data') . '/plugged')

" Python Formatter
Plug 'psf/black'

" Treesitter
" Docs recommend updating the parsers on update
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" GRUVBOX
Plug 'morhetz/gruvbox'

" Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" CoC
" Plug 'neoclide/coc.nvim', {'branch': 'release'} " Release
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'} " From Source

" Telescope and deps
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

call plug#end()

" ---------- Basic Remaps -----------
let mapleader = ","
let maplocalleader = ","


" ---------- CoC Plugins -----------
let g:coc_global_extensions = ['coc-go', 'coc-python', 'coc-sh', 'coc-spell-checker', 'coc-json']

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

" ---------- Telescope Commands ------------
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

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
