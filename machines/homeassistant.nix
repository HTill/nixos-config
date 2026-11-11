{ config, pkgs, lib, ... }:

# Home Assistant — smart-home hub on the homeserver.
# Web UI:  http://framework.local:8123  (home LAN/WLAN, mDNS)
#          http://framework.<tailnet>.ts.net:8123  (via Tailscale)
# First start: open the web UI and complete onboarding (creates the admin user).
# Data lives in /var/lib/hass and is included in the restic backup (homeserver.nix).
{
  services.home-assistant = {
    enable = true;
    configDir = "/var/lib/hass";
    config = {
      default_config = {};
      homeassistant = {
        name = "Home";
        unit_system = "metric";
        time_zone = "Europe/Berlin";
        currency = "EUR";
        country = "DE";
      };
      http = {
        server_host = "0.0.0.0";
        server_port = 8123;
      };
      logger.default = "info";
    };
    extraComponents = [
      "met"           # weather
      "esphome"       # ESPHome devices
      "tasmota"       # Tasmota devices
      "radio_browser"
    ];
    # extraPackages = python3Packages: with python3Packages; [ ... ];
  };
}
