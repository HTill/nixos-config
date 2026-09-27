{
  description = "NixOS + Home Manager configuration for multiple machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    
    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    
    # Optional: Additional overlays or modules
    # flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
    in {
      # NixOS configurations for different machines
      nixosConfigurations = {
        framework = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./machines/framework.nix
            # Include Home Manager for user 'till'
            home-manager.nixosModules.home-manager {
              home-manager.users.till = import ./home/till/default.nix;
            }
          ];
        };
        # Add more machines here, e.g.:
        # desktop = nixpkgs.lib.nixosSystem { ... };
      };

      # Home Manager configurations for different users
      homeConfigurations = {
        till@framework = home-manager.lib.homeManagerConfiguration {
          inherit system;
          configuration = import ./home/till/default.nix;
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
        ];
      };
    };
}
