{ config, pkgs, lib, ... }:

{
  # WiFi configuration module
  # NOTE: NetworkManager is a SYSTEM service, not a user service.
  # WiFi settings are configured at the SYSTEM level in machines/framework.nix
  # This module only contains user-level WiFi utilities

  # WiFi packages (user-level tools)
  home.packages = with pkgs; [
    iw  # WiFi configuration tool
    wavemon  # WiFi signal strength monitor
    nm-cli  # NetworkManager CLI
  ];

  # WiFi scripts (optional: auto-connect helper)
  home.file.".config/systemd/user/wifi-connect.service" = {
    source = pkgs.writeShellScriptBin "wifi-connect" ''
      #!${pkgs.bash}/bin/bash
      # Simple script to connect to WiFi
      if command -v nmcli &> /dev/null; then
        nmcli device wifi list
        echo "Use 'nmcli device wifi connect <SSID>' to connect"
      fi
    '';
    executable = true;
  };

  # Environment variables
  home.sessionVariables = {
    WIFI_INTERFACE = "wlp1s0";  # Anpassen an dein Interface (pruefe mit `ip a`)
  };
}
