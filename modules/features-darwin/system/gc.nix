{
  config,
  inputs,
  pkgs,
  ...
}: let
  user = config.system.primaryUser;
  userHome = config.users.users.${user}.home;

  colima =
    (import inputs.nixpkgs-unstable {
      inherit (pkgs.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    })
    .colima;

  nixBin = "/nix/var/nix/profiles/default/bin";

  dockerPrune = pkgs.writeShellScript "docker-prune" ''
    set -u
    if ! ${pkgs.docker_29}/bin/docker info >/dev/null 2>&1; then
      echo "colima is not running, nothing to prune"
      exit 0
    fi
    ${pkgs.docker_29}/bin/docker system prune -af --filter until=336h
    ${colima}/bin/colima ssh -- sudo fstrim -av
  '';
in {
  launchd.daemons.nix-gc = {
    command = "${nixBin}/nix-collect-garbage --delete-older-than 14d";
    serviceConfig = {
      StartCalendarInterval = [
        {
          Weekday = 0;
          Hour = 3;
          Minute = 0;
        }
      ];
      RunAtLoad = false;
      StandardOutPath = "/var/log/nix-gc.log";
      StandardErrorPath = "/var/log/nix-gc.log";
    };
  };

  launchd.user.agents.docker-prune = {
    command = "${dockerPrune}";
    serviceConfig = {
      StartCalendarInterval = [
        {
          Weekday = 0;
          Hour = 4;
          Minute = 0;
        }
      ];
      RunAtLoad = false;
      EnvironmentVariables.DOCKER_HOST = "unix://${userHome}/.colima/docker.sock";
      StandardOutPath = "${userHome}/.colima/docker-prune.log";
      StandardErrorPath = "${userHome}/.colima/docker-prune.log";
    };
  };
}
