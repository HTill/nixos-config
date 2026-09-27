{ config, pkgs, lib, ... }:

{
  # Home Manager configuration for user 'till'
  # Imports all modules from the modules directory
  
  imports = [
    ./modules/git.nix
    ./modules/ssh.nix
    ./modules/wifi.nix
    ./modules/gitlab.nix
    ./modules/shell.nix
    ./modules/packages.nix
    ./modules/fonts.nix
  ];

  # Home directory
  home.username = "till";
  home.homeDirectory = "/home/till";

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
}
