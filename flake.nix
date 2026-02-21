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

    packages = forAllSystems (
      pkgs: let
        pythonEnv = pkgs.python3.withPackages (ps: [
          ps.pillow
          ps.materialyoucolor
        ]);
      in rec {
        zshell-cli = pkgs.callPackage ./nix/zshell-cli.nix {};

        zshell = pkgs.callPackage ./nix {
          rev = self.rev or self.dirtyRev;
          stdenv = pkgs.clangStdenv;

          quickshell = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
            withX11 = false;
            withI3 = false;
          };

          app2unit = pkgs.callPackage ./nix/app2unit.nix {};

          inherit pythonEnv zshell-cli;
        };

        default = zshell;
      }
    );

    devShells = forAllSystems (pkgs: {
      default = let
        system = pkgs.stdenv.hostPlatform.system;
        shellPkg = self.packages.${system}.zshell;
        cliPkg = self.packages.${system}.zshell-cli;
      in
        pkgs.mkShell.override {stdenv = shellPkg.stdenv;} {
          inputsFrom = [
            shellPkg
            shellPkg.plugin
          ];

          packages = with pkgs; [
            shellPkg
            cliPkg

            material-symbols
            rubik
            nerd-fonts.caskaydia-cove
          ];
        };
    });
  };
}
