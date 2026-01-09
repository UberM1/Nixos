{
  config,
  pkgs,
  ...
}: {
  # Dolphin file manager configuration
  xdg.configFile."dolphinrc".text = ''
    [General]
    TerminalApplication=kitty
    Version=202
    ViewPropsTimestamp=2025,12,29,23,3,51.622

    [KFileDialog Settings]
    Places Icons Auto-resize=false
    Places Icons Static Size=22

    [MainWindow]
    MenuBar=Disabled

    [Desktop Action openKittyHere]
    Name=Open kitty Here
    Icon=kitty
    TryExec=kitty
    Exec=kitty --single-instance --directory %f
  '';
}
