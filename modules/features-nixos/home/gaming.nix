{
  pkgs,
  pkgs-unstable,
  ...
}: let
  fullTiltAssets = pkgs.fetchzip {
    url = "https://archive.org/download/full_tilt_pinball/CADET.zip";
    hash = "sha256-a/X02rU4FCOgEmdJZ8vb8fhYTZNrpC5shIHnS7XtZnc=";
    stripRoot = false;
  };
in {
  home.packages = with pkgs; [
    # discord
    # vesktop
    prismlauncher
    pkgs-unstable.lavat
    gamescope
    (space-cadet-pinball.overrideAttrs (old: {
      postInstall =
        old.postInstall
        + ''
          install -Dm644 ${fullTiltAssets}/CADET.{DAT,BMP} -t $out/share/SpaceCadetPinball
          install -Dm644 ${fullTiltAssets}/SOUND/* -t $out/share/SpaceCadetPinball/SOUND
        '';
    }))
    tor-browser
    discord

    (writeShellScriptBin "steam" ''
      exec ${util-linux}/bin/setpriv \
        --ambient-caps=-sys_nice \
        --inh-caps=-sys_nice,-setpcap \
        -- /run/current-system/sw/bin/steam "$@"
    '')
  ];
}
