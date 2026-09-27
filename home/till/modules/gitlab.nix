{ config, pkgs, lib, ... }:

{
  # GitLab configuration module
  
  # GitLab CLI (glab)
  home.packages = with pkgs; [
    glab  # GitLab CLI tool
  ];

  # GitLab environment variables
  home.sessionVariables = {
    GITLAB_USER = "HTill";
    # GITLAB_TOKEN wird NICHT hier gespeichert! (siehe README.md)
    GITLAB_HOST = "gitlab.com";
  };

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
