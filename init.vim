" Loading plugins 
call plug#begin('~/.config/nvim/plugged')   " specify plugin directory
Plug 'morhetz/gruvbox'                      " color scheme
Plug 'ap/vim-css-color'                     " color code plugin
Plug 'Raimondi/delimitMate'                 " automatic closing of quotes, parenthesis, brackets, etc
Plug 'gabrielelana/vim-markdown'            " markdown syntax
<<<<<<< HEAD
Plug 'SirVer/ultisnips'                     " snippet engine
Plug 'honza/vim-snippets'                   " snippets
=======
Plug 'airblade/vim-gitgutter'               " git version control system
>>>>>>> f507ad810e22d808246f2087ec9aca2a0a73b319
call plug#end()

" Settings
syntax on                                   " syntax highligth
set nocompatible                            " disable compatibility to old-time vi
set showmatch                               " show matching brackets
set ignorecase                              " case insensitive matching
set mouse=v                                 " mouse support in visual mode
set hlsearch                                " highlight search results
set autoindent                              " indent a new line the same amount as the line just typed
set number relativenumber                   " add relative line numbers
set cc=80                                   " set a mark at column 88
set textwidth=80                            " text width
set expandtab                               " convert tabs to white spaces
set tabstop=4                               " number of columns occupied by a tab character
set softtabstop=4                           " see multiple spaces as tab-stops so <BS> does the right thing
set shiftwidth=4                            " width for auto-indents
set wrap                                    " allow line wrapping
<<<<<<< HEAD
=======
set spell spelllang=en_us                   " spell check

syntax on
>>>>>>> f507ad810e22d808246f2087ec9aca2a0a73b319
set background=dark 
colorscheme gruvbox

" Ultisnip
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
let g:UltiSnipsEditSplit="vertical"
