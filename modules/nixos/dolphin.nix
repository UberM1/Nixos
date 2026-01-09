{
  config,
  pkgs,
  ...
}: {
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
    kdePackages.ark # archiving and compression support
    kdePackages.audiocd-kio # audio CD support
    kdePackages.baloo # extended tagging support
    kdePackages.dolphin-plugins # Git, Bazaar, Mercurial, Dropbox support
    kdePackages.kio-gdrive # Google Drive support

    # File preview thumbnailers
    kdePackages.kdegraphics-thumbnailers # image files, PDFs, Blender files
    kdePackages.ffmpegthumbs # video files
    kdePackages.kdesdk-thumbnailers # plugins for thumbnailing system
    kdePackages.kimageformats # Gimp .xcf, .heic files
    icoutils # .ico, .cur files and embedded .exe icons
    libappimage # embedded .AppImage icons
    qt6.qtimageformats # .webp, .tiff, .tga, .jp2 files
    resvg # fast and accurate SVG thumbnails
    taglib # audio files
  ];

  # Set kitty as default terminal for Dolphin
  environment.sessionVariables = {
    TERMINAL = "kitty";
  };
}
