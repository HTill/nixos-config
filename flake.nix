{
  description = "NixOS + Home Manager configuration for multiple machines";

  inputs = {
    # Current stable channel (26.05 "Yarara", May 2026 — required for KDE Plasma 6
    # and a kernel new enough for Framework 13 hardware)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware profiles (Framework Laptop 13 AMD Ryzen 7040 etc.)
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        # Framework Laptop 13 (AMD Ryzen 7040): desktop + local homeserver
        framework = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            nixos-hardware.nixosModules.framework-13-7040-amd
            ./machines/framework.nix
            ./machines/homeserver.nix
            home-manager.nixosModules.home-manager {
              home-manager.users.till = import ./home/till/home.nix;
            }
          ];
        };

        # Graphical installer ISO for the boot USB stick:
        #   nix build .#iso
        #   sudo dd if=$(echo result/iso/*.iso) of=/dev/sdX bs=4M status=progress conv=fsync
        installer = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical.nix"
            "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
            ./machines/base.nix
            {
              nixpkgs.config.allowUnfree = true;
              nix.settings.experimental-features = [ "nix-command" "flakes" ];
              networking.networkmanager.enable = true;
            }
          ];
        };
      };

      packages.${system}.iso =
        self.nixosConfigurations.installer.config.system.build.isoImage;

      # Home Manager configurations for different users
      homeConfigurations = {
        "till@framework" = home-manager.lib.homeManagerConfiguration {
          inherit system;
          configuration = import ./home/till/home.nix;
          pkgs = nixpkgs.legacyPackages.${system};
        };
      };

      # Dev shell for development
      devShells.${system}.default = let
        pkgs = nixpkgs.legacyPackages.${system};
      in pkgs.mkShell {
        packages = with pkgs; [
          git
          curl
          neovim
          htop
          tmux
          gh
          nixos-rebuild
          yq  # For YAML parsing
        ];
      };
    };
}
