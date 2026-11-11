{ config, pkgs, lib, ... }:

{
  # Firefox as the default browser (BROWSER=firefox is set in home.nix)
  programs.firefox.enable = true;
}
