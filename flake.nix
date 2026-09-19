{
  description = "Sid's darwin system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    username = "siddeshsambasivam";
  in
  {
    # Named after LocalHostName, which is what `darwin-rebuild --flake .`
    # looks up when you don't spell out an attribute.
    darwinConfigurations."sids-macbook" = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit username; };
      modules = [
        ./darwin.nix

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit username; };
          home-manager.users.${username} = import ./home.nix;

          # Without this the first switch aborts rather than touch an
          # existing hand-written ~/.zshrc. It renames them instead.
          home-manager.backupFileExtension = "pre-hm";
        }

        # Needs `self`, so it stays here rather than in darwin.nix.
        # Makes `darwin-version` report the commit this was built from.
        { system.configurationRevision = self.rev or self.dirtyRev or null; }
      ];
    };
  };
}
