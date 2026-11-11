{ config, pkgs, lib, ... }:

{
  imports = [
    ./base.nix
    # Load secrets from user's secrets.yaml (gitignored, never committed)
    ../home/till/secrets-helper.nix
  ];

  # Machine-specific settings for Framework Laptop 13 (AMD Ryzen 7040).
  # Hardware quirks (lid switch, amdgpu, power management, fingerprint reader)
  # come from nixos-hardware.nixosModules.framework-13-7040-amd in flake.nix.
  networking.hostName = "framework";

  # Bootloader (systemd-boot for UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # Kernel & Firmware (AMD 7040)
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkForce false;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.firmware = [ pkgs.linuxFirmware ];

  # Networking — WLAN auto-connect via secrets.yaml, LAN via DHCP (plug & play)
  networking.networkmanager.enable = true;
  networking.wireless.enable = true;
  # WiFi networks from secrets.yaml (auto-connect at home)
  networking.wireless.networks = config.secrets.wifi.networks;

  # Bluetooth (headset etc.)
  hardware.bluetooth.enable = true;

  # SSH Server (port 22; Forgejo uses its own SSH on 2222, see homeserver.nix)
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  # Desktop: KDE Plasma 6 + SDDM
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  # Docker daemon (user 'till' is already in the "docker" group below)
  virtualisation.docker.enable = true;

  # Users
  users.users.till = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" "kvm" "libvirtd" ];
    # Public SSH key for authentication (NOT private key!)
    openssh.authorizedKeys.keys = [
      config.secrets.ssh.public_key  # Public key from secrets.yaml
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
    htop
    tmux
    neofetch
    gh
    nixos-rebuild
    fwupd
    firefox
  ];

  # Power management (power-profiles-daemon is recommended for AMD 7040)
  services.power-profiles-daemon.enable = true;
  powerManagement.enable = true;

  # Audio
  security.polkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Graphics (amdgpu is handled by the nixos-hardware profile)
  hardware.graphics.enable = true;

  # Touchpad
  services.libinput.enable = true;

  # Time & locales
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Swap
  swapDevices = [
    { device = "/swapfile"; priority = 1000; size = 4096; }
  ];

  # File systems (ANPASSEN an die Partitionen der Installation!)
  fileSystems."/" = {
    device = "/dev/nvme0n1p2";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
    mountOptions = [ "defaults" "umask=0077" ];
  };

  # System state version
  system.stateVersion = "26.05";
}
