{ config, pkgs, lib, ... }:

# Optional: Neovim configuration as a separate module
# Import this in home/till/default.nix if you want Neovim

{
  programs.neovim = {
    enable = true;
    
    # Neovim version (default is latest)
    # version = "stable";
    
    # Configuration
    configure = {
      customRC = ''
        " Configuration goes here
        " Basic settings
        set number
        set tabstop=2
        set shiftwidth=2
        set expandtab
        set smartindent
        set autoindent
        set mouse=a
        
        " Filetype settings
        filetype plugin indent on
        syntax on
        
        " Search settings
        set incsearch
        set hlsearch
        set ignorecase
        set smartcase
        
        " Line numbers
        set relativenumber
        
        " Theme (if installed)
        " colorscheme gruvbox
        
        " Plugins (if using vim-plug or similar)
        " call plug#begin('~/.local/share/nvim/plugged')
        " Plug 'neovim/nvim-lspconfig'
        " call plug#end()
      '';
      
      # Plugins (using nixpkgs)
      plugins = with pkgs.vimPlugins; [
        # Add your plugins here
        # vim-sensible
        # nerdtree
        # vim-airline
        # vim-fugitive
      ];
    };
    
    # Enable LSP (Language Server Protocol)
    withPython3 = true;
    withNodeJs = true;
  };

  # Neovim packages
  home.packages = with pkgs; [
    neovim
    # Language servers (optional)
    # python3Packages.python-lsp-server
    # nodePackages.typescript-language-server
    # rust-analyzer
  ];
}
