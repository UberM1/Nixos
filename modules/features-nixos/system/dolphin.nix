{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    kdePackages.dolphin
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
}
