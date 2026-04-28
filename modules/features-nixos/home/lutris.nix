{pkgs-unstable, ...}: {
  programs.lutris = {
    enable = true;
    winePackages = [pkgs-unstable.wineWow64Packages.stagingFull];
    defaultWinePackage = pkgs-unstable.wineWow64Packages.stagingFull;
    extraPackages = with pkgs-unstable; [
      winetricks
      fuseiso
      xrandr
    ];

    runners.wine.settings.system = {
      disable_runtime = true;
    };
  };
}
