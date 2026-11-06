{pkgs, ...}: let
  # Full Tilt! Pinball (Maxis, 1995) — the retail game whose Space Cadet table
  # Windows later shipped cut down. Its CADET.DAT is what gives multiball,
  # jackpots, hi-res art and three music tracks; the Windows PINBALL.DAT that
  # nixpkgs bundles hands out extra balls instead of locking them. Pulled from
  # archive.org, same as the Windows assets in the upstream derivation.
  fullTiltAssets = pkgs.fetchzip {
    url = "https://archive.org/download/full-tilt-pinball-windows-11-portable-en/Full-Tilt-Pinball_Win_EN.zip";
    hash = "sha256-I2iS9anu4itLxecujn4vmjg9R07Z2a1T8A0W9cy8Vyw=";
  };

  # k4zmu2a's reimplementation picks its table by scanning each data directory
  # for CADET.DAT before PINBALL.DAT, and on macOS the first directory it looks
  # at is the bundle's Resources/. So swapping what lands there is the whole
  # change: Full Tilt data in, Windows data out. FT keeps its sounds and music
  # in a SOUND/ subfolder and carries its own font inside CADET.DAT, so there
  # is no FONT.DAT to install.
  space-cadet-pinball = pkgs.space-cadet-pinball.overrideAttrs (_: prev: let
    resources = "$out/Applications/SpaceCadetPinball.app/Contents/Resources";
    cadet = "${fullTiltAssets}/FULLTILT/CADET";
  in {
    postInstall = ''
      install -Dm644 ${cadet}/CADET.{DAT,BMP} -t ${resources}
      install -Dm644 ${cadet}/SOUND/*.{WAV,MID} -t ${resources}/SOUND
    '';

    meta = prev.meta // {description = prev.meta.description + " (Full Tilt! table data)";};
  });
in {
  home.packages = [space-cadet-pinball];
}
