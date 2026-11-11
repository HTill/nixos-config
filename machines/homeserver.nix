{ config, pkgs, lib, ... }:

# Local homeserver services on the Framework laptop.
# Reachable from anywhere via Tailscale (WireGuard) and inside the home
# LAN/WLAN as "framework.local" (mDNS). Never exposed to the public internet.
{
  # --- Tailscale: encrypted access from anywhere (phone, other laptops) ---
  services.tailscale.enable = true;

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
  # Tailscale interface is fully trusted (Forgejo + SSH reachable via VPN).
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  # Inside the home LAN/WLAN (private RFC1918 ranges only) allow Forgejo
  # HTTP (3000) and git+SSH (2222) — nothing is exposed to the public internet.
  networking.firewall.extraCommands = ''
    ip46tables -A nixos-fw -p tcp -s 192.168.0.0/16 --dport 3000 -j nixos-fw-accept
    ip46tables -A nixos-fw -p tcp -s 192.168.0.0/16 --dport 2222 -j nixos-fw-accept
    ip46tables -A nixos-fw -p tcp -s 10.0.0.0/8     --dport 3000 -j nixos-fw-accept
    ip46tables -A nixos-fw -p tcp -s 10.0.0.0/8     --dport 2222 -j nixos-fw-accept
    ip46tables -A nixos-fw -p tcp -s 172.16.0.0/12  --dport 3000 -j nixos-fw-accept
    ip46tables -A nixos-fw -p tcp -s 172.16.0.0/12  --dport 2222 -j nixos-fw-accept
  '';

  environment.systemPackages = with pkgs; [
    forgejo
    restic
  ];

  # --- Encrypted offsite backup of the Forgejo data (zero-knowledge restic) ---
  # One-time manual setup (files live OUTSIDE the nix store on purpose):
  #   sudo mkdir -p /root/.config/restic /root/.secrets
  #   sudo sh -c 'openssl rand -base64 36 > /root/.secrets/restic-forgejo.password && chmod 600 /root/.secrets/restic-forgejo.password'
  #   sudoedit /root/.config/restic/restic.env
  #     RESTIC_REPOSITORY=sftp:uXXXXX@uXXXXX.your-storagebox.de:23/restic-forgejo
  #     RESTIC_PASSWORD_FILE=/root/.secrets/restic-forgejo.password
  #     RESTIC_CACHE_DIR=/root/.cache/restic
  systemd.services.restic-forgejo-backup = {
    description = "restic encrypted backup of /var/lib/forgejo (zero-knowledge offsite)";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = with pkgs; [ restic openssh bash coreutils ];
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = "/root/.config/restic/restic.env";
      ExecStart = pkgs.writeShellScript "restic-forgejo-backup" ''
        restic unlock --remove-all 2>/dev/null || true
        restic backup /var/lib/forgejo --tag forgejo --host framework
        restic forget --prune --tag forgejo --host framework \
          --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --keep-yearly 2
        restic check --read-data-subset=5%
      '';
    };
  };
  systemd.timers.restic-forgejo-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 04:00";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };
}
