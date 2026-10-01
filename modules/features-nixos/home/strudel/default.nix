# Local Strudel live-coding REPL served on localhost so it runs without strudel.cc
{pkgs, ...}: let
  strudel = pkgs.callPackage ./package.nix {};
  port = 4321;
in {
  systemd.user.services.strudel = {
    Unit.Description = "Strudel live-coding REPL";
    Service = {
      ExecStart = "${pkgs.static-web-server}/bin/static-web-server --host 127.0.0.1 --port ${toString port} --root ${strudel} --compression-static";
      Restart = "on-failure";
    };
    Install.WantedBy = ["default.target"];
  };

  xdg.desktopEntries.strudel = {
    name = "Strudel";
    comment = "Live-code music in the browser";
    exec = "${pkgs.xdg-utils}/bin/xdg-open http://localhost:${toString port}/";
    icon = "${strudel}/icon.png";
    categories = ["Audio" "Development"];
  };
}
