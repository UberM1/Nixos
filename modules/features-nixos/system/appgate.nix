{
  pkgs,
  lib,
  ...
}: let
  # El cliente filtra su LD_LIBRARY_PATH (nss viejo) al navegador del SSO (Okta).
  # Interponemos un xdg-open que limpia el entorno antes de abrir el browser real.
  clean-xdg-open = pkgs.writeShellScriptBin "xdg-open" ''
    exec ${pkgs.coreutils}/bin/env -u LD_LIBRARY_PATH ${pkgs.xdg-utils}/bin/xdg-open "$@"
  '';
  # GUI de Appgate con ese xdg-open primero en el PATH, para que el login Okta abra limpio
  appgate-wrapped = pkgs.symlinkJoin {
    name = "appgate-sdp-ssofix";
    paths = [pkgs.appgate-sdp];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/appgate --prefix PATH : ${clean-xdg-open}/bin
    '';
  };
in {
  # Cliente VPN Appgate SDP (perfil Okta de tecval): monta el driver como servicio
  programs.appgate-sdp.enable = true;
  # La GUI wrappeada gana en PATH (hiPrio) para arrastrar el xdg-open limpio
  environment.systemPackages = [(lib.hiPrio appgate-wrapped)];
}
