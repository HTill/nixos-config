# NixOS + Home Manager Configuration

This repository contains **NixOS system configurations** and **Home Manager user configurations** for multiple machines, organized in a **modular** way.

## Structure

```
nixos-config/
├── flake.nix                      # Main flake with inputs and outputs
├── machines/                      # Machine-specific NixOS configurations
│   ├── default.nix               # Default settings for ALL machines
│   ├── framework.nix             # Framework Laptop configuration
│   └── ...                       # Add more machines here
└── home/                         # Home Manager configurations
    └── till/                     # User 'till' configurations
        ├── default.nix          # Main config (imports all modules)
        ├── editors/             # Optional: Editor configurations
        │   └── neovim.nix       # Neovim configuration (disabled by default)
        └── modules/             # Modular configurations
            ├── git.nix         # Git + GitHub CLI
            ├── ssh.nix         # SSH + GPG Agent
            ├── wifi.nix        # WiFi + NetworkManager
            ├── gitlab.nix      # GitLab CLI + config
            ├── shell.nix       # ZSH + Starship prompt
            ├── packages.nix    # General packages (NO editors)
            └── fonts.nix       # Fonts configuration
```

## Key Features

✅ **Modular Design** - Each feature (SSH, WiFi, Git, etc.) is a separate module
✅ **Multi-Machine Support** - Add as many machines as you need
✅ **Multi-User Support** - Each user can have their own configuration
✅ **No Secrets in Git** - Sensitive data is handled separately
✅ **Flakes Support** - Reproducible builds

## Quick Start

### 1. Clone and enter the repository

```bash
cd /home/till/projects/nixos-config
```

### 2. Build and activate for Framework Laptop

```bash
# NixOS System rebuilden:
sudo nixos-rebuild switch --flake .#framework

# Home-Manager für Benutzer 'till' aktivieren:
home-manager switch --flake .#till@framework
```

### 3. Update all flake inputs

```bash
nix flake update
```

## Module Overview

Each module in `home/till/modules/` handles a specific aspect:

| Module | Purpose | Key Features |
|--------|---------|--------------|
| **git.nix** | Git configuration | Aliases, user info, credential helper |
| **ssh.nix** | SSH settings | Agent, known hosts, config file |
| **wifi.nix** | WiFi configuration | NetworkManager, power save |
| **gitlab.nix** | GitLab integration | glab CLI, API config |
| **shell.nix** | Shell setup | ZSH + Starship prompt |
| **packages.nix** | General packages | Utilities, dev tools (NO editors) |
| **fonts.nix** | Fonts | Fira Code, JetBrains Mono, Noto Fonts |

## Adding a New Machine

### Step 1: Create machine configuration

```bash
# Create new machine file
nano machines/<machine-name>.nix
```

Example (`machines/desktop.nix`):
```nix
{ config, pkgs, lib, ... }:

{
  imports = [
    ./default.nix  # Include default settings
  ];

  networking.hostName = "desktop";
  
  # Machine-specific settings
  boot.loader.systemd-boot.enable = true;
  
  # Include Home Manager for user 'till'
  home-manager.users.till = import ../home/till/default.nix;
}
```

### Step 2: Add to flake.nix

Edit `flake.nix` and add the new machine:
```nix
nixosConfigurations = {
  framework = nixpkgs.lib.nixosSystem { ... };
  desktop = nixpkgs.lib.nixosSystem { ... };  # Add this
};
```

### Step 3: Add Home Manager configuration

```nix
homeConfigurations = {
  till@framework = home-manager.lib.homeManagerConfiguration { ... };
  till@desktop = home-manager.lib.homeManagerConfiguration { ... };  # Add this
};
```

## Adding a New User

### Step 1: Create user directory

```bash
mkdir -p home/<username>/modules
```

### Step 2: Create modules for the user

Create module files in `home/<username>/modules/` following the same pattern.

### Step 3: Create default.nix

```nix
# home/<username>/default.nix
{ config, pkgs, lib, ... }:
{
  imports = [
    ./modules/git.nix
    ./modules/ssh.nix
    # ... other modules
  ];
  
  home.username = "<username>";
  home.homeDirectory = "/home/<username>";
}
```

### Step 4: Add to machine configuration

In your machine's configuration:
```nix
home-manager.users.<username> = import ../home/<username>/default.nix;
```

## Enabling Neovim (Optional)

Neovim is **NOT** included by default (as requested). To enable it:

1. Add the module to `home/till/default.nix`:
```nix
imports = [
  ./modules/git.nix
  ./modules/ssh.nix
  ./modules/wifi.nix
  ./modules/gitlab.nix
  ./modules/shell.nix
  ./modules/packages.nix
  ./modules/fonts.nix
  ./editors/neovim.nix  # Add this line
];
```

2. Rebuild Home Manager:
```bash
home-manager switch --flake .#till@framework
```

## Customizing Modules

### Git Module (`modules/git.nix`)

Edit to customize:
- User name and email
- Git aliases
- Default branch
- Credential helpers

### SSH Module (`modules/ssh.nix`)

Edit to customize:
- SSH known hosts
- SSH config options
- SSH keys (store private keys in `~/.ssh/`, not in Git!)

### WiFi Module (`modules/wifi.nix`)

Edit to customize:
- WiFi power save settings
- NetworkManager options
- WiFi interface name

### GitLab Module (`modules/gitlab.nix`)

**IMPORTANT:** Never commit your GitLab token!

Create a secret file:
```bash
# Create encrypted token (requires age)
echo "your-gitlab-token" | age -e -i ~/.config/age/keys.txt -o secrets/gitlab-token.age
```

Then load it in your configuration:
```nix
# In machines/framework.nix or similar
secrets.gitlabToken = builtins.readFile ./secrets/gitlab-token.age;
```

### Shell Module (`modules/shell.nix`)

Edit to customize:
- Shell aliases
- ZSH plugins
- Starship prompt appearance

### Packages Module (`modules/packages.nix`)

Add/remove packages here. **Editors are NOT included by default** (as requested).

## Secrets Management

**⚠️ NEVER commit secrets to GitHub!**

### Using age encryption (recommended)

1. Install age:
```bash
nix-env -iA nixpkgs.age
```

2. Generate key pair:
```bash
age-keygen -o ~/.config/age/keys.txt
```

3. Encrypt a secret:
```bash
echo "my-secret-password" | age -e -i ~/.config/age/keys.txt -o secrets/wifi-password.age
```

4. Add to .gitignore:
```
# .gitignore
secrets/
*.age
*.age-key
age.age-key
```

5. Load in configuration:
```nix
# In your module
secrets.wifiPassword = builtins.readFile ./secrets/wifi-password.age;
```

### Using environment variables

```bash
# In your shell profile
 export GITLAB_TOKEN="your-token"
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

## Common Customizations

### Change timezone

In `machines/framework.nix`:
```nix
time.timeZone = "Europe/Berlin";
```

### Add a new package

In `home/till/modules/packages.nix`:
```nix
home.packages = with pkgs; [
  # ... existing packages
  spotify
  discord
];
```

### Change shell prompt

In `home/till/modules/shell.nix`:
```nix
programs.starship.settings.format = "$all";
```

### Add SSH key

1. Generate key:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github
```

2. Add to SSH module:
```nix
# In home/till/modules/ssh.nix
ssh.extraConfig = ''
  Host github.com
    IdentityFile ~/.ssh/id_ed25519_github
'';
```

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [NixOS Wiki](https://nixos.wiki/)
- [age Encryption](https://age-encryption.org/)

## License

This configuration is provided as-is. Use at your own risk.
