{ config, pkgs, ... }:

{
  imports = [
    # Framework Laptop specific configurations
    # <nixpkgs/nixos/modules/installer/scan/not-detected.nix>  # Uncomment if needed
  ];

  # Bootloader (systemd-boot for UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # Kernel & Firmware (for Framework laptop hardware)
  boot.kernelPackages = pkgs.linuxPackages_testing;
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  # Networking
  networking.hostName = "framework";
  networking.hostId = "deadbeef";
  
  # Ethernet (auto-detect)
  networking.networkmanager.enable = true;
  
  # WiFi (for Framework laptops)
  networking.wireless.enable = true;
  hardware.pulseaudio.enable = true;

  # SSH Server (accessible from network)
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";
  services.openssh.passwordAuthentication = true;
  services.openssh.authorizedKeysFiles = [ 
    "/home/till/.ssh/authorized_keys" 
  ];

  # Users
  users.users.till = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" "kvm" "libvirtd" ];
    openssh.authorizedKeys.keys = [
      # Add your SSH public key here
      # "ssh-rsa AAAAB3NzaC1yc2E..."
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
    gh  # GitHub CLI
    nixos-rebuild
    # Framework specific tools
    fwupd
    power-profiles-daemon
  ];

  # Enable Flakes (modern Nix)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System state version
  system.stateVersion = "23.11";

  # Power management (for laptop)
  powerManagement.cpuFreqGovernor = "powersave";
  powerManagement.enable = true;

  # Audio
  security.polkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Display (for Framework laptop with Intel/AMD graphics)
  hardware.graphics.enable = true;
  hardware.opengl.enable = true;

  # Touchpad
  services.libinput.enable = true;

  # Time
  time.timeZone = "Europe/Berlin";

  # Locales
  i18n.defaultLocale = "de_DE.UTF-8";

  # NixOS rebuild options
  nixpkgs.config.allowUnfree = true;

  # Systemd services
  systemd.packages = with pkgs; [ networkmanager ];

  # Framework Laptop specific: Enable all firmware
  hardware.firmware = [ (pkgs.firmware).allFirmware ];

  # Swap file (for laptops with limited RAM)
  swapDevices = [
    { device = "/swapfile"; priority = 1000; size = 4096; }
  ];

  # File systems
  fileSystems."/" = {
    device = "/dev/nvme0n1p2";  # Anpassen an deine Partition!
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/nvme0n1p1";  # Anpassen!
    fsType = "vfat";
    mountOptions = [ "defaults" "umask=0077" ];
  };

  # NixOS module system
  system.modules = [
    ({ config, ... }: {
      # Custom configurations can go here
    })
  ];
}
