{
  lib,
  config,
  ...
}: let
  c = config.lib.stylix.colors;
  # Stylix exposes each channel pre-converted to decimal, e.g. base00-rgb-r.
  rgb = base: "${c."${base}-rgb-r"},${c."${base}-rgb-g"},${c."${base}-rgb-b"}";

  # KColorScheme requires these exact key names (BackgroundNormal, not
  # BackgroundColor); unknown keys are ignored and missing ones fall back
  # to Breeze's light palette.
  colorSection = bg: alt: fg: ''
    BackgroundNormal=${rgb bg}
    BackgroundAlternate=${rgb alt}
    ForegroundNormal=${rgb fg}
    ForegroundActive=${rgb "base0C"}
    ForegroundInactive=${rgb "base04"}
    ForegroundLink=${rgb "base0D"}
    ForegroundNegative=${rgb "base08"}
    ForegroundNeutral=${rgb "base0A"}
    ForegroundPositive=${rgb "base0B"}
    ForegroundVisited=${rgb "base0E"}
    DecorationFocus=${rgb "base0D"}
    DecorationHover=${rgb "base0D"}
  '';
in {
  # KDE apps (Dolphin) only read kdeglobals when the Qt platform theme is
  # plasma-integration; qt6ct/qtct replace the palette and bypass it.
  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "kde";
    style.name = lib.mkForce "breeze";
  };

  xdg.configFile."kdeglobals".text = ''
    [General]
    ColorScheme=Stylix

    [KDE]
    widgetStyle=Breeze

    [Icons]
    Theme=breeze-dark

    [Colors:Window]
    ${colorSection "base00" "base01" "base05"}
    [Colors:View]
    ${colorSection "base00" "base01" "base05"}
    [Colors:Button]
    ${colorSection "base01" "base02" "base05"}
    [Colors:Tooltip]
    ${colorSection "base01" "base02" "base05"}
    [Colors:Complementary]
    ${colorSection "base00" "base01" "base05"}
    [Colors:Header]
    ${colorSection "base01" "base02" "base05"}
    [Colors:Selection]
    BackgroundNormal=${rgb "base0D"}
    BackgroundAlternate=${rgb "base0D"}
    ForegroundNormal=${rgb "base00"}
    ForegroundActive=${rgb "base00"}
    ForegroundInactive=${rgb "base01"}
    ForegroundLink=${rgb "base00"}
    ForegroundNegative=${rgb "base08"}
    ForegroundNeutral=${rgb "base0A"}
    ForegroundPositive=${rgb "base0B"}
    ForegroundVisited=${rgb "base00"}
    DecorationFocus=${rgb "base0D"}
    DecorationHover=${rgb "base0D"}

    [WM]
    activeBackground=${rgb "base01"}
    activeForeground=${rgb "base05"}
    inactiveBackground=${rgb "base00"}
    inactiveForeground=${rgb "base04"}
  '';

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

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = "nvim-kitty.desktop";
      "text/x-shellscript" = "nvim-kitty.desktop";
      "application/json" = "nvim-kitty.desktop";
      "text/x-python" = "nvim-kitty.desktop";
      "application/pdf" = "firefox.desktop";
    };
    # Allow user choices to override these defaults
    associations.removed = {
      "application/pdf" = ["chromium-browser.desktop"];
    };
  };
}
