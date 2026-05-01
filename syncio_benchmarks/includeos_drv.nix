{
    includeos_path ? ""
}
:
let
    includeos = import includeos_path {};
    stdenv = includeos.stdenv;
in
stdenv.mkDerivation {
    name = "VirtioFS_bench IncludeOS";
    version = "dev";
    src = ./src;

    inherit (includeos) nativeBuildInputs;

    cmakeFlags = [
      "-DCMAKE_CXX_STANDARD=20"
      "-DUNIKERNEL=1"
    ];

    buildInputs = [
        includeos
    ];

    installPhase = ''
        mkdir -p $out/bin
        cp virtiofs_bench.elf.bin $out/bin/virtiofs_bench
    '';
}