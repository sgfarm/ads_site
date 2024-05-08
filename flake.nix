{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ ];
        pkgs = (import nixpkgs) {
          inherit system overlays;
        };

        src = ./.;

        book = pkgs.stdenv.mkDerivation {
          inherit src;
          name = "ads-book";
          buildInputs = [ pkgs.mdbook ];
          buildCommand = ''
            mkdir $out
            cp -r $src/* .
            mdbook build -d $out
          '';
        };

        container = pkgs.dockerTools.buildLayeredImage {
          name = "ads-book-server";
          tag = "latest";
          contents = [ pkgs.cacert ];
          config = {
            Entrypoint = [ "${pkgs.tini}/bin/tini" "${pkgs.static-web-server}/bin/static-web-server" "--" ];
            Cmd = [ "-p" "3000" "-d" "${book}" ];
          };
        };
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            mdbook flyctl
          ];
        };
        packages = {
          inherit book container;
          default = book;
        };
      });
}
