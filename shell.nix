# https://status.nixos.org
{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/a62844b302507c7531ad68a86cb7aa54704c9cb4.tar.gz") {} }:


pkgs.mkShell {
  buildInputs = with pkgs; [
    bmake
    unixtools.column # For help makefile generator
    curl
    packer
  ];
}
