{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    # discord
    # vesktop
    prismlauncher
    pkgs-unstable.lavat
    gamescope
    tor-browser

    (writeShellScriptBin "steam" ''
      exec ${util-linux}/bin/setpriv \
        --ambient-caps=-sys_nice \
        --inh-caps=-sys_nice,-setpcap \
        -- /run/current-system/sw/bin/steam "$@"
    '')
  ];
}
