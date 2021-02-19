{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = false;
    package = pkgs.neovim;
    plugins = with pkgs.vimPlugins; [
      vim-surround
      vim-commentary
      auto-pairs
      vim-fugitive
      vim-gitgutter
    ];
    extraConfig = ''
      set clipboard=unnamedplus " Use system clipboard
      set hidden                " Buffers persist in the background
      " Enable mouse support
      set mouse=a
      " Keep 5 line padding on cursor
      set scrolloff=5
      " Numbering
      set number
      set cursorline
      " Wildmenu
      set wildmenu
      set wildmode=list:longest,full " enable completion via tab
      " Panes
      set splitright
      set splitbelow
      " Indentation and Folding
      set autoindent
      set copyindent
      set shiftround
      set foldmethod=indent
      set nofoldenable
      " Search
      set smartcase
      set incsearch
      " Tabs
      set tabstop=4
      set softtabstop=0
      set expandtab
      set shiftwidth=4
      set smarttab
      " Text
      setlocal textwidth=80
      setlocal conceallevel=0
      "Swap Files
      set noswapfile
      " History and Undo Levels
      set undolevels=99999
      set history=1000
      set undofile
      set undodir=~/.local/share/nvim/undodir
      " Colors
      syntax on
      set termguicolors
      " colorscheme NeoSolarized
      colorscheme nord
      set background=dark
      " Filetype Recognition
      filetype on
      filetype plugin on
      filetype indent on
      " Finding files
      set path+=**
      " Highlight whitespace
      highlight ExtraWhitespace ctermbg=red guibg=red
      match ExtraWhitespace /\s\+$/
      autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
      autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
      autocmd InsertLeave * match ExtraWhitespace /\s\+$/
      autocmd BufWinLeave * call clearmatches()

      " move by visual lines
      nnoremap j gj
      nnoremap k gk

      " Statusline
      function! GitBranch()
        return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
      endfunction
      function! StatuslineGit()
        let l:branchname = GitBranch()
        return strlen(l:branchname) > 0?'  '.l:branchname.' ':\'\'
      endfunction
      set laststatus=2 " Always on statusline
      set statusline=
      set statusline+=%#PmenuSel#
      set statusline+=%{StatuslineGit()}
      set statusline+=%#LineNr#
      set statusline+=\ %.30F            " Truncated file path
      set statusline+=%m\                " Modified flag
      set statusline+=%=                 " Align the following to the right:
      set statusline+=%#CursorColumn#
      set statusline+=\ %y               " Filetype
      set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
      set statusline+=\[%{&fileformat}\] " File format
      set statusline+=\ %p%%             " Percentage through file
      set statusline+=\ %l:%c            " Line number:column number
      set statusline+=\                  " Add a space at the end
    '';
  };
}
