{pkgs, ...}: {
  programs.sketchybar = {
    service.enable = false;
    enable = false;
    configType = "lua";
    sbarLuaPackage = pkgs.sbarlua;
  };
}
