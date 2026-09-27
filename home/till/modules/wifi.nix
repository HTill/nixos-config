{ config, pkgs, lib, ... }:

{
  # WiFi configuration module
  
  # NetworkManager settings for WiFi
  services.networkmanager = {
    enable = true;
    wifi.powersave = 2;  # 0 = disabled, 1 = low, 2 = medium, 3 = high
    wifi.backgroundScan = "yes:60";
  };

  # WiFi packages
  home.packages = with pkgs; [
    networkmanagerapplet  # GUI for NetworkManager (optional)
    iw  # WiFi configuration tool
    wavemon  # WiFi signal strength monitor
    nm-cli  # NetworkManager CLI
  ];

  # WiFi scripts (optional: auto-connect to known networks)
  home.file.".config/systemd/user/wifi-connect.service" = {
    source = pkgs.writeShellScriptBin "wifi-connect" ''
      #!${pkgs.bash}/bin/bash
      # Connect to WiFi on startup
      nmcli connection up "$(nmcli -t -f NAME,TYPE connection show | grep wireless | head -n1 | cut -d: -f1)" 2>/dev/null || true
    '';
    executable = true;
  };

  # Environment variables
  home.sessionVariables = {
    WIFI_INTERFACE = "wlp1s0";  # Anpassen an dein Interface (pruefe mit `ip a`)
  };
}
