{pkgs, ...}: {
  home.packages = with pkgs; [
    freerdp
    postgresql
    vault
    sqlcmd
  ];
}
