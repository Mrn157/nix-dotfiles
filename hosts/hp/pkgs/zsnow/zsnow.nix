{ pkgs,  ... }:
  pkgs.stdenv.mkDerivation {
  pname = "zsnow";
  version = "release";
    
  src = pkgs.fetchurl {
        url = "https://github.com/Mrn157/ZSnoW/releases/download/release/zsnow.tar.xz";
        sha256 = "sha256-a2Z7aLXB8NmnUXT4UcS7hvndkAWquqpPdBsbnoSYncU=";
  };
  installPhase = ''
    mkdir -p $out/bin
    cp zsnow $out/bin/
    chmod +x $out/bin/*
  '';
}
