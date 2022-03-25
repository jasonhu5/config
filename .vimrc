execute pathogen#infect()
syntax on
colorscheme desert

set number
set mouse=a
set tabstop=2

set shiftwidth=0
set softtabstop=2
set expandtab
set smarttab
set autoindent

set ruler
set showmatch

imap jk <Esc>

set laststatus=2

map <Tab> <C-W>w

" Toggle nerdtree
map <F2> :NERDTreeToggle<CR>

" Highlight cursor
" set cursorline
" set cursorcolumn
" hi CursorLine   cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white
" hi CursorColumn cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white

" highlight search
set hlsearch
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>
:noremap <F4> :set hlsearch! hlsearch?<CR>

" search
set incsearch  " start searching while inputting text
set ignorecase
set smartcase

" toggle paste and nopaste modes
:noremap <F3> :set nopaste! paste?<CR>

" text folding
" set foldmethod=indent
nnoremap <silent> <F9> @=(foldlevel('.')?'za':"\<Space>")<CR>
vnoremap <F9> zf

" search
map <F12> *<C-O>:%s///gn<CR>

" remap autocomplete to avoid keybinding conflict with tmux
inoremap <Nul> <C-n>
