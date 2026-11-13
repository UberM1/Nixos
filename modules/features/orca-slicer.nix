{pkgs, ...}: let
  # nixpkgs only builds orca-slicer for Linux, and homebrew is off on the mac,
  # so darwin gets the upstream universal DMG repackaged into the store. It's
  # APFS, which undmg can't read — 7zz can.
  orca-slicer-darwin = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "orca-slicer";
    version = "2.5.0";

    src = pkgs.fetchurl {
      url = "https://github.com/OrcaSlicer/OrcaSlicer/releases/download/v${version}/OrcaSlicer_Mac_universal_V${version}.dmg";
      hash = "sha256-Bh4Mb/EEw3ZVyDGQclrCQglg8jw5tWqum1RubFQpldU=";
    };

    nativeBuildInputs = [pkgs._7zz];
    sourceRoot = ".";
    unpackPhase = "7zz x -snld $src";
    # The bundle is signed; patchShebangs on its embedded python breaks the seal.
    dontFixup = true;

    installPhase = ''
      mkdir -p $out/Applications
      cp -R OrcaSlicer.app $out/Applications/
    '';

    meta = pkgs.orca-slicer.meta // {platforms = pkgs.lib.platforms.darwin;};
  };
in {
  home.packages = [
    (
      if pkgs.stdenv.isDarwin
      then orca-slicer-darwin
      else pkgs.orca-slicer
    )
  ];
}
