{pkgs, ...}: let
  # Bake the env into the binary so Dolphin is themed and finds apps no
  # matter how it's launched (terminal, rofi, noctalia, xdg-open):
  # - QT_QPA_PLATFORMTHEME=kde -> plasma-integration reads kdeglobals colors
  # - kbuildsycoca6 keeps the "Open with" application cache fresh
  dolphin-wrapped = pkgs.symlinkJoin {
    name = "dolphin-wrapped";
    paths = [pkgs.kdePackages.dolphin];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/dolphin \
        --set QT_QPA_PLATFORMTHEME kde \
        --set QT_STYLE_OVERRIDE breeze \
        --run "${pkgs.kdePackages.kservice}/bin/kbuildsycoca6 >/dev/null 2>&1 || true"
    '';
  };
in {
  environment.systemPackages = with pkgs; [
    dolphin-wrapped
    kdePackages.kio
    kdePackages.kdf
    kdePackages.kio-fuse
    kdePackages.kio-extras
    kdePackages.kio-admin
    kdePackages.qtwayland
    kdePackages.plasma-integration
    kdePackages.breeze-icons
    kdePackages.qtsvg
    kdePackages.kservice

    # Additional Dolphin functionality
    kdePackages.ark
    kdePackages.audiocd-kio
    kdePackages.baloo
    kdePackages.dolphin-plugins
    kdePackages.kio-gdrive

    # File preview thumbnailers
    kdePackages.kdegraphics-thumbnailers
    kdePackages.ffmpegthumbs
    kdePackages.kdesdk-thumbnailers
    kdePackages.kimageformats
    icoutils
    libappimage
    qt6.qtimageformats
    resvg
    taglib
  ];

  environment.sessionVariables = {
    TERMINAL = "kitty";
  };

  environment.etc."xdg/menus/applications.menu".source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
}
