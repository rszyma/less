{
  description = "A very basic flake";

  # Testing:
  # cat /dev/urandom | tr -dc '!-~' | fold -w 120 | nix run . -- -# 2
  # cat /dev/urandom | tr -dc '!-~' | fold -w 120 | LESS_TERMCAP_SUSPEND=$'\e[?2026h' LESS_TERMCAP_RESUME=$'\e[?2026l' nix run . -- -# 2

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = {
        less = nixpkgs.legacyPackages.${system}.less.overrideAttrs (finalAttrs: {
          src = ./.;
          version = "684";
          nativeBuildInputs = (finalAttrs.nativeBuildInputs or [ ]) ++ [
            pkgs.autoreconfHook
            pkgs.perl
          ];
          postPatch = ''
            patchShebangs .
            make -f Makefile.aut all
            make -f Makefile.aut './less.nro'
            make -f Makefile.aut './lesskey.nro'
            make -f Makefile.aut './lessecho.nro'
          '';
        });
        default = self.packages.${system}.less;
      };
    };
}
