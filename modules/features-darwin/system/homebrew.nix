{...}: {
  homebrew = {
    enable = true;
    taps = [
      "FelixKratz/formulae"
    ];
    brews = [
      "mas"
      "mysql-client@8.0"
      "libyaml"
      "zstd"
      "shared-mime-info"
      "switchaudio-osx"
    ];
    casks = [
      "docker"
      "visual-studio-code"
      "google-chrome"
      "firefox"
      "kitty"
      "sf-symbols"
    ];
    onActivation.cleanup = "uninstall";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };
}
