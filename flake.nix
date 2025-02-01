{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
    in flake-utils.lib.eachSystem systems (system:
      let
        pkgs = import nixpkgs { inherit system; };
        R-packages = pkgs.rWrapper.override {
          packages = with pkgs.rPackages; [
            portfolioBacktest
            gdata
            bayesplot
            testit
            posterior
            remotes
            rstan
            CVXR
            ggplot2
            dplyr
            xts
          ];
        };

      in {
        devShell = pkgs.mkShell {

          packages = with pkgs; [
            gcc
	          stdenv.cc.cc
            R-packages
            jq
            gnuplot
            curl
	          pkg-config
            zlib
          ];

	        DISPLAY=":0";
          LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib;${pkgs.zlib.dev}/lib";
	
          shellHook = ''
                echo "Hello shell"
                Rscript install.r
          '';

        };
      });
}
