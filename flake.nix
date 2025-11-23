{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    forAllSystems = fn:
      nixpkgs.lib.genAttrs nixpkgs.lib.platforms.linux (
        system: fn nixpkgs.legacyPackages.${system}
      );
  in {
    formatter = forAllSystems (pkgs: pkgs.alejandra);

    packages = forAllSystems (pkgs: rec {
      zshell = pkgs.callPackage ./nix {
        rev = self.rev or self.dirtyRev;
        stdenv = pkgs.clangStdenv;
        quickshell = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
          withX11 = false;
          withI3 = false;
        };
        app2unit = pkgs.callPackage ./nix/app2unit.nix {inherit pkgs;};
      };
      debug = zshell.override {debug = true;};
      default = zshell;
    });

    devShells = forAllSystems (pkgs: {
      default = let
        shell = self.packages.${pkgs.stdenv.hostPlatform.system}.zshell;
      in
        pkgs.mkShell.override {stdenv = shell.stdenv;} {
          inputsFrom = [shell shell.plugin];
          packages = with pkgs; [clazy material-symbols rubik nerd-fonts.caskaydia-cove];
        };
    });
  };
}
