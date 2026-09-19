{
  description = "Sid's darwin system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }: {

    # Named after LocalHostName, which is what `darwin-rebuild --flake .`
    # looks up when you don't spell out an attribute.
    darwinConfigurations."sids-macbook" = nix-darwin.lib.darwinSystem {
      modules = [
        ./darwin.nix

        # Needs `self`, so it stays here rather than in darwin.nix.
        # Makes `darwin-version` report the commit this was built from.
        { system.configurationRevision = self.rev or self.dirtyRev or null; }
      ];
    };
  };
}
