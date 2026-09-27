{ config, pkgs, lib, ... }:

{
  # Home Manager configuration for user 'till'
  # This can be used across different machines

  # Home directory
  home.username = "till";
  home.homeDirectory = "/home/till";

  # Basic home packages
  home.packages = with pkgs; [
    # Terminal & Shell
    zsh
    starship
    bat
    exa
    fd
    ripgrep
    fzf
    
    # Editors
    neovim
    micro
    
    # Git & Development
    git
    gh
    git-lfs
    
    # Utilities
    htop
    tmux
    wget
    curl
    jq
    yq
    
    # File management
    rclone
    tree
    
    # Python
    python3
    python3Packages.pip
    python3Packages.virtualenv
    
    # Node.js (optional)
    # nodejs
    # yarn
    
    # Rust (optional)
    # rustc
    # cargo
  ];

  # Shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    plugins = [
      { name = "zsh-autosuggestions"; }
      { name = "zsh-syntax-highlighting"; }
    ];
    promptInit = ''
      autoload -U promptinit; promptinit
      prompt spower10k
    '';
  };

  # Starship prompt (modern shell prompt)
  programs.starship = {
    enable = true;
    defaultUserFormat = "$user"";
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "HTill";
    userEmail = "tillh.spitz@t-online.de";
    core = {
      editor = "nvim";
      pager = "bat";
    };
    init.defaultBranch = "main";
  };

  # Neovim configuration
  programs.neovim = {
    enable = true;
    configure = {
      customRC = ''
        set number
        set tabstop=2
        set shiftwidth=2
        set expandtab
        syntax on
        filetype plugin indent on
      '';
    };
    plugins = with pkgs.vimPlugins; [
      # Add your favorite plugins here
      # vim-sensible
      # nerdtree
    ];
  };

  # TMUX configuration
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g prefix C-a
      set -g base-index 1
      set -g pane-base-index 1
      set -g mouse on
    '';
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    PAGER = "bat";
    BROWSER = "firefox";
  };

  # XDG directories
  xdg.configFile = {
    "user-dirs.dirs".text = ''
      XDG_DESKTOP_DIR="$HOME/Desktop"
      XDG_DOWNLOAD_DIR="$HOME/Downloads"
      XDG_TEMPLATES_DIR="$HOME/Templates"
      XDG_PUBLICSHARE_DIR="$HOME/Public"
      XDG_DOCUMENTS_DIR="$HOME/Documents"
      XDG_MUSIC_DIR="$HOME/Music"
      XDG_PICTURES_DIR="$HOME/Pictures"
      XDG_VIDEOS_DIR="$HOME/Videos"
    '';
  };

  # SSH configuration
  ssh = {
    enable = true;
    knownHosts = {
      github.com = {
        hostName = "github.com";
        user = "HTill";
        port = 22;
      };
    };
  };

  # Docker configuration (optional)
  # docker.enable = true;

  # Flatpak configuration (optional)
  # flatpak.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    (callPackage /home/till/projects/nixos-config/home/till/fonts.nix {})
    # Or use pre-built packages:
    # fira-code
    # jetbrains-mono
    # noto-fonts
    # noto-fonts-cjk
    # noto-fonts-emoji
  ];
}
