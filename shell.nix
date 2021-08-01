{ pkgs ? import <nixpkgs> {}}:

let
  unstable = import (fetchTarball https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) {};
  hy = unstable.python3.pkgs.buildPythonPackage rec {
    pname = "hy";
    version = "0.20.0";
    src = unstable.python3.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "1b72863754fb57e2dd275a9775bf621cb50a565e76733a2e74e9954e7fbb060e";
    };
    doCheck = false;
    propagatedBuildInputs = with unstable.python3Packages; [
      astor colorama funcparserlib rply
    ];
  };
  python = unstable.python3.withPackages (ps: with ps; [ pynvim hy ]);
in
  pkgs.mkShell {
    nativeBuildInputs = with pkgs; [
      unstable.mitscheme
      unstable.guile
      unstable.racket
      unstable.janet
      unstable.chicken
    ];
  }
