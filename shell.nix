{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  hardeningDisable = [ "all" ];
  buildInputs = with pkgs; [
    jekyll
    bundler
  ];
}
