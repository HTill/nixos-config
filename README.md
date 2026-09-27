# NixOS Configuration for Framework Laptop

This repository contains the NixOS configuration for my Framework Laptop.

## Features

- **Systemd-boot** for UEFI
- **SSH Server** enabled (accessible from network)
- **NetworkManager** for easy network configuration
- **WiFi** support for Framework laptops
- **Power management** optimized for laptops
- **Framework-specific firmware** included
- **Flakes** support enabled

## Quick Start

### 1. Install NixOS on Framework Laptop

Boot from NixOS minimal ISO and run:

```bash
# Partition your disk (adjust to your needs)
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart primary fat32 1MiB 512MiB
parted /dev/nvme0n1 -- mkpart primary ext4 512MiB 100%
parted /dev/nvme0n1 -- set 1 esp on

# Format partitions
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2
mkswap /dev/nvme0n1p3
swapon /dev/nvme0n1p3

# Mount
mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

# Generate config
nixos-generate-config --root /mnt

# Copy this config
cp /path/to/this/configuration.nix /mnt/etc/nixos/configuration.nix

# Install
nixos-install --root /mnt
```

### 2. After Installation

```bash
# Update system
sudo nixos-rebuild switch --upgrade

# Enable SSH access
sudo systemctl enable --now sshd

# Connect to WiFi (if needed)
nmtui
```

### 3. SSH Access from Network

The system is configured to allow SSH access. After installation:

```bash
# Find your IP
ip a

# Connect from another machine
ssh till@<your-ip>
```

## Configuration

Edit `configuration.nix` to customize:
- **Hostname**: Change `networking.hostName`
- **Users**: Add users in the `users.users` section
- **SSH Keys**: Add your public keys in `users.users.<name>.openssh.authorizedKeys.keys`
- **Partitioning**: Adjust `fileSystems` to match your disk layout
- **Timezone**: Change `time.timeZone`

## Framework Laptop Specifics

- **Firmware**: All redistributable firmware is enabled
- **Graphics**: Intel/AMD graphics support included
- **Power**: Optimized for battery life
- **Touchpad**: Libinput configured

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Framework Laptop Docs](https://frame.work/)
- [NixOS on Framework](https://nixos.wiki/wiki/Framework)

## License

This configuration is provided as-is. Use at your own risk.
