{
  includeos_path ? "",
}
:
let
  includeos = import includeos_path {};
  stdenv = includeos.stdenv;
  pkgs = includeos.pkgs;
in
pkgs.mkShell.override { inherit (includeos) stdenv; } {
  packages = [
    includeos.vmrunner
    stdenv.cc
    pkgs.buildPackages.cmake
    pkgs.buildPackages.nasm
    pkgs.qemu
    pkgs.virtiofsd
    pkgs.which
    pkgs.grub2
    pkgs.iputils
  ];

  buildInputs = [
    includeos
    includeos.chainloader
  ];

  bootloader="${includeos}/boot/bootloader";
}
