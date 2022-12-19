" Loading plugins 
call plug#begin('~/.config/nvim/plugged')   " specify plugin directory
Plug 'morhetz/gruvbox'                      " color scheme
Plug 'ap/vim-css-color'                     " color code plugin
Plug 'Raimondi/delimitMate'                 " automatic closing of quotes, parenthesis, brackets, etc
Plug 'gabrielelana/vim-markdown'            " markdown syntax
Plug 'airblade/vim-gitgutter'               " git version control system
call plug#end()

" Settings
set nocompatible                            " disable compatibility to old-time vi
set showmatch                               " show matching brackets
set ignorecase                              " case insensitive matching
set mouse=v                                 " mouse support in visual mode
set hlsearch                                " highlight search results
set autoindent                              " indent a new line the same amount as the line just typed
set number relativenumber                   " add relative line numbers
set cc=88                                   " set a mark at column 88
set tabstop=4                               " number of columns occupied by a tab character
set expandtab                               " convert tabs to white spaces
set shiftwidth=4                            " width for auto-indents
set softtabstop=4                           " see multiple spaces as tab-stops so <BS> does the right thing
set wrap                                    " allow line wrapping
set spell spelllang=en_us                   " spell check

syntax on
set background=dark 
colorscheme gruvbox

