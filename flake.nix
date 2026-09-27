{
  description = "NixOS configuration for Framework Laptop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    
    # Optional: Add other inputs like home-manager
    # home-manager.url = "github:nix-community/home-manager";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      framework = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          # Optional: Add hardware-specific modules
          # ({ config, pkgs, ... }: {
          #   nixpkgs.overlays = [
          #     (self: super: {
          #       # Custom packages can go here
          #     })
          #   ];
          # })
        ];
      };
    };
  };
}
