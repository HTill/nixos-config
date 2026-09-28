{ config, pkgs, lib, ... }:

{
  # Shell configuration module (zsh + starship)
  
  # ZSH Shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    
    plugins = [
      { name = "zsh-autosuggestions"; }
      { name = "zsh-syntax-highlighting"; }
      { name = "zsh-history-substring-search"; }
    ];
    
    # Shell aliases
    shellAliases = {
      ll = "exa -la --git --icons";
      ls = "exa -la --git --icons";
      la = "exa -la --git --icons";
      cat = "bat";
      v = "nano";
      e = "nano";
      g = "git";
      h = "history";
      hg = "history | grep";
      p = "ping";
      c = "clear";
      .. = "cd ..";
      ... = "cd ../..";
    };
    
    # Environment variables
    extraShellConfig = ''
      HISTFILE=~/.zsh_history
      HISTSIZE=1000000
      SAVEHIST=1000000
      setopt appendhistory
      setopt incappendhistory
      setopt sharehistory
      
      # Auto cd
      setopt autocd
      
      # Correct commands
      setopt correct
      
      # Pushd
      setopt pushdignoredups
      setopt pushdminus
    '';
  };

  # Starship prompt (modern, cross-shell)
  programs.starship = {
    enable = true;
    
    settings = {
      format = "$all"
      
      # Prompt sections
      add_newline = true
      
      # Username
      user = {
        show_always = true;
        style_user = "bg:blue fg:white bold";
        style_root = "bg:red fg:white bold";
        format = "[$user]($style) ";
      };
      
      # Hostname
      hostname = {
        ssh_only = false;
        format = "[$hostname]($style) ";
        style = "bg:green fg:white bold";
      };
      
      # Directory
      directory = {
        truncation_length = 3;
        style = "bg:purple fg:white bold";
        format = "[$path]($style) ";
      };
      
      # Git
      git_branch = {
        symbol = " ";
        style = "bg:yellow fg:black bold";
        format = "[$symbol$branch]($style) ";
      };
      git_status = {
        format = "([\[$all_status$ahead_behind\]]($style) )"
        style = "bg:yellow fg:black";
      };
      
      # Character
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vicmd_symbol = "[❮](bold yellow)";
      };
    };
  };

  # Shell packages
  home.packages = with pkgs; [
    zsh
    starship
    exa
    bat
    fd
    ripgrep
    fzf
    thefuck
    zoxide
  ];

  # Default shell
  programs.zsh.enableAsDefault = true;
}
