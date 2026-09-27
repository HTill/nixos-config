{ config, pkgs, lib, ... }:

{
  imports = [
    # Base configuration for all machines
    ./default.nix
  ];

  # Machine-specific settings for Framework Laptop
  networking.hostName = "framework";
  
  # Bootloader (systemd-boot for UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # Kernel & Firmware
  boot.kernelPackages = pkgs.linuxPackages_testing;
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  # Networking
  networking.networkmanager.enable = true;
  networking.wireless.enable = true;
  
  # NetworkManager WiFi settings (system-level)
  networking.networkmanager.wifi = {
    powersave = 2;  # 0 = disabled, 1 = low, 2 = medium, 3 = high
    backgroundScan = "yes:60";
  };

  # SSH Server
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  # Users
  users.users.till = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" "kvm" "libvirtd" ];
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
    power-profiles-daemon
  ];

  # Power management
  powerManagement.cpuFreqGovernor = "powersave";
  powerManagement.enable = true;

  # Audio
  security.polkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Display
  hardware.graphics.enable = true;
  hardware.opengl.enable = true;

  # Touchpad
  services.libinput.enable = true;

  # Time
  time.timeZone = "Europe/Berlin";

  # Locales
  i18n.defaultLocale = "de_DE.UTF-8";

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Swap
  swapDevices = [
    { device = "/swapfile"; priority = 1000; size = 4096; }
  ];

  # File systems (ANPASSEN an deine Partitionen!)
  fileSystems."/" = {
    device = "/dev/nvme0n1p2";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
    mountOptions = [ "defaults" "umask=0077" ];
  };

  # Framework-specific: Enable all firmware
  hardware.firmware = [ (pkgs.firmware).allFirmware ];

  # System state version
  system.stateVersion = "23.11";
}
