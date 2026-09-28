{ config, pkgs, lib, ... }:

{
  # Default configuration for all machines
  # This is imported by all machine-specific configurations

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Basic system settings
  boot.supportedFilesystems = [ "ntfs" "btrfs" "zfs" "ext4" "f2fs" ];
  
  # Enable necessary services
  services.udev.packages = with pkgs; [ gnupg ];
  
  # Time synchronization
  services.ntp = {
    enable = true;
    daemonType = "systemd-timesyncd";
  };

  # Enable DNS caching
  services.dnsmasq.enable = true;

  # Basic hardware support
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  # Basic networking
  networking.hostId = "deadbeef";

  # Basic users
  users.users.till = {
    isNormalUser = true;
    description = "Till";
  };

  # Basic packages
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
    htop
  ];

  # Basic locales
  i18n.supportedLocales = [ "de_DE.UTF-8" "en_US.UTF-8" ];
  i18n.defaultLocale = "de_DE.UTF-8";

  # Basic system settings
  system.stateVersion = "23.11";
}
