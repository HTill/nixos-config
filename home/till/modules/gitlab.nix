{ config, pkgs, lib, ... }:

{
  imports = [
    ../secrets-helper.nix  # Load secrets from YAML
  ];

  # GitLab configuration module
  # ⚠️  SECRETS: Loaded from secrets.yaml (not in git)
  
  # GitLab CLI (glab)
  home.packages = with pkgs; [
    glab  # GitLab CLI tool
  ];

  # GitLab Token from secrets.yaml
  home.sessionVariables.GITLAB_TOKEN = config.secrets.gitlab.token;

  # GitLab configuration file
  xdg.configFile."glab-cli/config.yml".text = ''
    host: gitlab.com
    token: ${config.secrets.gitlab.token}
    api_host: gitlab.com
    git_protocol: https
    browser: firefox
  '';

  # Git configuration for GitLab
  programs.git.extraConfig = {
    url."git@gitlab.com:".insteadOf = "git://gitlab.com/";
    url."git@gitlab.com:".insteadOf = "https://gitlab.com/";
  };

  # Aliases for GitLab
  programs.git.aliases.gl = "!glab";
}
