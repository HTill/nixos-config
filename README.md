# NixOS + Home Manager Configuration

This repository contains **NixOS system configurations** and **Home Manager user configurations** for multiple machines.

## Structure

```
nixos-config/
├── flake.nix                      # Main flake with inputs and outputs
├── machines/                      # Machine-specific NixOS configurations
│   ├── default.nix               # Default settings for all machines
│   ├── framework.nix             # Framework Laptop configuration
│   └── ...                       # Add more machines here
└── home/                         # Home Manager configurations
    └── till/                     # User 'till' configurations
        ├── default.nix          # Default home configuration
        └── fonts.nix             # Custom fonts
```

## Quick Start

### 1. Clone and enter the repository

```bash
cd /home/till/projects/nixos-config
```

### 2. Build and activate for a specific machine

```bash
# For Framework Laptop
sudo nixos-rebuild switch --flake .#framework

# For Home Manager (user 'till' on Framework)
home-manager switch --flake .#till@framework
```

### 3. Update all flake inputs

```bash
nix flake update
```

## Adding a New Machine

### Step 1: Create machine configuration

Create a new file in `machines/` (e.g., `machines/desktop.nix`):

```nix
{ config, pkgs, lib, ... }:

{
  imports = [
    ./default.nix  # Include default settings
  ];

  networking.hostName = "desktop";
  
  # Machine-specific settings
  boot.loader.systemd-boot.enable = true;
  
  # Add Home Manager for user
  home-manager.users.till = import ../home/till/default.nix;
}
```

### Step 2: Add to flake.nix

Edit `flake.nix` and add the new machine to `nixosConfigurations`:

```nix
nixosConfigurations = {
  framework = nixpkgs.lib.nixosSystem { ... };
  desktop = nixpkgs.lib.nixosSystem { ... };  # Add this
};
```

### Step 3: Add Home Manager configuration

Add a new entry to `homeConfigurations`:

```nix
homeConfigurations = {
  till@framework = home-manager.lib.homeManagerConfiguration { ... };
  till@desktop = home-manager.lib.homeManagerConfiguration { ... };  # Add this
};
```

## Adding a New User

### Step 1: Create user directory

```bash
mkdir -p home/<username>
```

### Step 2: Create default.nix

Create `home/<username>/default.nix` with the user's Home Manager configuration.

### Step 3: Add to machine configuration

In your machine's configuration (e.g., `machines/framework.nix`):

```nix
home-manager.users.<username> = import ../home/<username>/default.nix;
```

## Usage Examples

### Rebuild NixOS

```bash
# For Framework Laptop
sudo nixos-rebuild switch --flake .#framework

# For another machine
sudo nixos-rebuild switch --flake .#desktop
```

### Update Home Manager

```bash
# For user 'till' on Framework
home-manager switch --flake .#till@framework

# For user 'till' on Desktop
home-manager switch --flake .#till@desktop
```

### Enter development shell

```bash
nix develop  # Uses devShell from flake.nix
```

### Update all inputs

```bash
nix flake update
```

## Framework Laptop Specifics

The `machines/framework.nix` configuration includes:

- **systemd-boot** for UEFI
- **NetworkManager** for network management
- **Wireless** support
- **SSH Server** enabled
- **Power management** optimized for laptops
- **Framework-specific firmware**
- **Touchpad** support (libinput)
- **PipeWire** for audio

## Customization

### System-wide settings

Edit files in `machines/` to customize system configuration for each machine.

### User-specific settings

Edit files in `home/<username>/` to customize user environments.

### Adding packages

Add packages to:
- `machines/<machine>/default.nix` for system-wide packages
- `home/<user>/default.nix` for user-specific packages

## Secrets Management

**Never commit secrets to GitHub!**

For sensitive data (passwords, API keys):

1. **Use age encryption** (recommended):
   ```bash
   age-keygen -o age.age-key
   echo "my-secret" | age -e -i age.age-key -o secrets/my-secret.age
   ```

2. **Add to .gitignore**:
   ```
   age.age-key
   secrets/
   *.age
   ```

3. **Load in configuration**:
   ```nix
   secrets = builtins.fromJSON (builtins.readFile ./secrets/my-secret.age);
   ```

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [NixOS Wiki](https://nixos.wiki/)

## License

This configuration is provided as-is. Use at your own risk.
