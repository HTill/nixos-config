{ config, pkgs, lib, ... }:

# Local homeserver services on the Framework laptop.
# Reachable from anywhere via Tailscale (WireGuard) and inside the home
# LAN/WLAN as "framework.local" (mDNS). Never exposed to the public internet.
{
  # --- Tailscale: DISABLED for now — we stay in the home LAN/WLAN only.
  # Later (access from anywhere), either enable Tailscale here:
  #   services.tailscale.enable = true;
  # or better, for full privacy: self-host headscale (services.headscale) instead.
  services.tailscale.enable = false;

  # --- mDNS/Avahi: "framework.local" inside the home WLAN/LAN ---
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      workstation = true;
    };
  };

  # --- Forgejo: your own private Git server (no Microsoft/GitHub needed) ---
  services.forgejo = {
    enable = true;
    stateDir = "/var/lib/forgejo";
    database.type = "sqlite3";
    settings = {
      server = {
        DOMAIN = "framework";
        HTTP_PORT = 3000;
        ROOT_URL = "http://framework:3000/";
        # Forgejo's own SSH server on port 2222 (system sshd already uses 22).
        # git clone ssh://git@framework:2222/<user>/<repo>.git
        START_SSH_SERVER = true;
        SSH_PORT = 2222;
        SSH_DOMAIN = "framework";
      };
      service.DISABLE_REGISTRATION = true; # only you can create accounts
      security.INSTALL_LOCK = true;
      repository.DEFAULT_PRIVATE = true;   # new repos are private by default
      "lfs".START_SERVER = true;
    };
  };

  # --- Firewall ---
  # Nothing exposed to the public internet: no globally open TCP ports.
  # These ports are open only from private LAN/WLAN ranges (RFC1918):
  #   22 ssh · 3000 forgejo http · 2222 forgejo git-ssh · 8123 home-assistant
  # (When Tailscale/Headscale gets enabled later, also add "tailscale0"
  #  to trustedInterfaces so the services are reachable via VPN too.)
  networking.firewall.allowedTCPPorts = lib.mkForce [ ];
  networking.firewall.extraCommands =
    let
      ports = [ 22 3000 2222 8123 ];
      nets = [ "192.168.0.0/16" "10.0.0.0/8" "172.16.0.0/12" ];
    in
    lib.concatMapStrings
      (port: lib.concatMapStrings (net: ''
        ip46tables -A nixos-fw -p tcp -s ${net} --dport ${toString port} -j nixos-fw-accept
      '') nets)
      ports;

  environment.systemPackages = with pkgs; [
    forgejo
    restic
  ];

  # --- Encrypted offsite backup of the homeserver data (zero-knowledge restic) ---
  # Backs up /var/lib/forgejo and /var/lib/hass (Home Assistant).
  # One-time manual setup (files live OUTSIDE the nix store on purpose):
  #   sudo mkdir -p /root/.config/restic /root/.secrets
  #   sudo sh -c 'openssl rand -base64 36 > /root/.secrets/restic-homeserver.password && chmod 600 /root/.secrets/restic-homeserver.password'
  #   sudoedit /root/.config/restic/restic.env
  #     RESTIC_REPOSITORY=sftp:uXXXXX@uXXXXX.your-storagebox.de:23/restic-homeserver
  #     RESTIC_PASSWORD_FILE=/root/.secrets/restic-homeserver.password
  #     RESTIC_CACHE_DIR=/root/.cache/restic
  systemd.services.restic-homeserver-backup = {
    description = "restic encrypted backup of /var/lib/forgejo + /var/lib/hass (zero-knowledge offsite)";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = with pkgs; [ restic openssh bash coreutils ];
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = "/root/.config/restic/restic.env";
      ExecStart = pkgs.writeShellScript "restic-homeserver-backup" ''
        restic unlock --remove-all 2>/dev/null || true
        restic backup /var/lib/forgejo /var/lib/hass --tag homeserver --host framework
        restic forget --prune --tag homeserver --host framework \
          --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --keep-yearly 2
        restic check --read-data-subset=5%
      '';
    };
  };
  systemd.timers.restic-homeserver-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 04:00";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };
}
