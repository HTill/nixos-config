{ config, pkgs, lib, ... }:

{
  # Git configuration module
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
    
    # Credential helper (uses gh CLI for GitHub)
    credential.helper = "cache --timeout=3600";
    
    # Diff tool
    diff.tool = "delta";
    
    # Merge tool
    merge.tool = "vdiff";
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
}
