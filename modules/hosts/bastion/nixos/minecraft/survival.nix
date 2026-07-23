{pkgs, ...}: let
  minecraftMods = import ./mods.nix {inherit pkgs;};
in {
  services.minecraft-servers = {
    enable = false;
    eula = true;
    openFirewall = true;
    dataDir = "/mnt/data/minecraft";

    servers.minecraft-server = {
      enable = true;
      autoStart = true;
      openFirewall = true;

      # Fabric server for 1.21.11
      package = pkgs.fabricServers.fabric-1_21_11;

      jvmOpts = "-Xmx6144M -Xms6144M";

      serverProperties = {
        spawn-protection = 0;
        server-port = 25565;
        gamemode = "survival";
        difficulty = "hard";
        view-distance = 32;
        simulation-distance = 10;
        enable-rcon = true;
        "rcon.port" = 25575;
        "rcon.password" = "yourpassword123";
        motd = "Vanilla Server";
        enable-lan-visibility = "true";
      };

      # Install server-side mods using files (copies, not symlinks)
      # This allows mods like LuckPerms to create subdirectories
      files = {
        mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues minecraftMods);
      };
    };
  };
}
