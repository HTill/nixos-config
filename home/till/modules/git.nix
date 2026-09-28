{ config, pkgs, lib, ... }:

{
  imports = [
    ../secrets-helper.nix  # Load secrets from YAML
  ];

  # Git configuration module
  # ⚠️  SECRETS: Loaded from secrets.yaml (not in git)
  
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
    delta
    git-extras
  ];

  # GitHub Token from secrets.yaml
  home.sessionVariables.GITHUB_TOKEN = config.secrets.github.token;
}
