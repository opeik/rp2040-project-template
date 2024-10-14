{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [(import rust-overlay)];
        };
      in {
        # Nix code formatter: `nix fmt`
        formatter = pkgs.alejandra;

        # Development shell: `nix develop`
        devShell = pkgs.mkShell {
          packages = [
            self.formatter.${system}
            pkgs.flip-link
            pkgs.probe-rs-tools
            (pkgs.rust-bin.stable.latest.default.override
              {
                extensions = ["rust-src"];
                targets = ["thumbv6m-none-eabi"];
              })
          ];
        };
      }
    );
}
