{
  description = "Flake for zshell";
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
    forAllSystems = fn: nixpkgs.lib.genAttrs nixpkgs.lib.platforms.linux (system: fn nixpkgs.legacyPackages.${system});
  in {
    formatter = forAllSystems (pkgs: pkgs.nixfmt);

    packages = forAllSystems (pkgs: let
      pythonEnv = pkgs.python3.withPackages (ps: [
        ps.pillow
        ps.materialyoucolor
      ]);
    in rec {
      zshell = pkgs.callPackage ./nix {
        rev = self.rev or self.dirtyRev;
        stdenv = pkgs.clangStdenv;
        quickshell = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
          withX11 = false;
          withI3 = false;
        };
        app2unit = pkgs.callPackage ./nix/app2unit.nix {inherit pkgs;};

        inherit pythonEnv;
      };

      default = zshell;
    });

    devShells = forAllSystems (pkgs: {
      default = let
        shell = self.packages.${pkgs.stdenv.hostPlatform.system}.zshell;
      in
        pkgs.mkShell.override {stdenv = shell.stdenv;} {
          inputsFrom = [
            shell
            shell.Plugins
          ];
          packages = with pkgs; [
            material-symbols
            rubik
            nerd-fonts.caskaydia-cove
          ];
        };
    });
  };
}
