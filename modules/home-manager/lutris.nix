{
  pkgs,
  pkgs-unstable,
  ...
}: {
  programs.lutris = {
    enable = true;
    winePackages = [pkgs-unstable.wineWow64Packages.stagingFull];
    defaultWinePackage = pkgs-unstable.wineWow64Packages.stagingFull;
    extraPackages = with pkgs-unstable; [
      winetricks
      fuseiso
      xrandr
    ];

    # Configuración del runner wine para NixOS
    runners.wine.settings.system = {
      disable_runtime = true;  # Deshabilita el runtime de Lutris que no es compatible con NixOS
    };
  };
}
