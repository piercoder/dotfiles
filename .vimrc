" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

" Loading plugins 
call plug#begin('~/.vim/plugged')   	    " specify plugin directory
Plug 'sainnhe/sonokai'                      " color scheme
Plug 'ap/vim-css-color'                     " color code plugin
Plug 'Raimondi/delimitMate'                 " automatic closing of quotes, parenthesis, brackets, etc
Plug 'gabrielelana/vim-markdown'            " markdown syntax
Plug 'honza/vim-snippets'                   " snippets
Plug 'airblade/vim-gitgutter'               " git version control system
Plug 'tpope/vim-eunuch'                     " sudo and unix command
call plug#end()

" Settings
syntax on                                   " syntax highlight
set nocompatible                            " disable compatibility to old-time vi
set showmatch                               " show matching brackets
set ignorecase                              " case insensitive matching
set smartcase                               " smart case matching (it goes together with ignorecase)
set incsearch                               " incremental search
set mouse=a                                 " mouse support
set hlsearch                                " highlight search results
set autoindent                              " indent a new line the same amount as the line just typed
set number relativenumber                   " add relative line numbers
set cc=80                                   " set a mark at column 80
set textwidth=80                            " text width
set expandtab                               " convert tabs to white spaces
set tabstop=4                               " number of columns occupied by a tab character
set softtabstop=4                           " see multiple spaces as tab-stops so <BS> does the right thing
set shiftwidth=4                            " width for auto-indents
set wrap                                    " allow line wrapping
set linebreak                               " avoid wrapping a line in the middle of a word.
set spell spelllang=en_us,it                " spell check
set background=dark 
colorscheme sonokai
