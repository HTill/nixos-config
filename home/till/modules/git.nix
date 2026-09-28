{ config, pkgs, lib, ... }:

{
  # Git configuration module
  # ⚠️  SECRETS: Diese Datei NICHT in Git pushen! (steht in .gitignore)
  
  programs.git = {
    enable = true;
    
    # User identity
    userName = "HTill";
    userEmail = "tillh.spitz@t-online.de";
    
    # Core settings
    core = {
      editor = "nano";
      pager = "bat";
      autocrlf = "input";
      safecrlf = "warn";
    };
    
    # Init settings
    init.defaultBranch = "main";
    
    # Aliases
    aliases = {
      co = "checkout";
      br = "branch";
      ci = "commit";
      st = "status";
      df = "diff";
      lg = "log --oneline --decorate --graph";
      lga = "log --oneline --decorate --graph --all";
    };
    
    # Credential helper
    credential.helper = "cache --timeout=3600";
    
    # Diff tool
    diff.tool = "delta";
  };

  # Git LFS (optional)
  programs.git-lfs.enable = true;

  # GitHub CLI
  programs.gh.enable = true;
  
  # Git packages
  home.packages = with pkgs; [
    git
    git-lfs
    gh
    delta  # Better diff viewer
    git-extras  # Additional git utilities
  ];

  # ⚠️  SECRET: GitHub Personal Access Token
  # Ersetze das mit deinem echten Token von https://github.com/settings/tokens
  # Format: github_pat_11A... oder ghp_...
  home.sessionVariables.GITHUB_TOKEN = "DEIN_GITHUB_TOKEN_HIER";
}
