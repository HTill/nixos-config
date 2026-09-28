{ config, pkgs, lib, ... }:

{
  # GitLab configuration module
  # ⚠️  SECRETS: Diese Datei NICHT in Git pushen! (steht in .gitignore)
  
  # GitLab CLI (glab)
  home.packages = with pkgs; [
    glab  # GitLab CLI tool
  ];

  # ⚠️  SECRET: GitLab Personal Access Token
  # Ersetze das mit deinem echten Token von https://gitlab.com/-/profile/personal_access_tokens
  # Format: glpat-xxxxxxxxxxxxx
  home.sessionVariables.GITLAB_TOKEN = "DEIN_GITLAB_TOKEN_HIER";

  # GitLab configuration file
  xdg.configFile."glab-cli/config.yml".text = ''
    host: gitlab.com
    token: ${config.home.sessionVariables.GITLAB_TOKEN}
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
