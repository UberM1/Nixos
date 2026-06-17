{pkgs, ...}: let
  minecraftMods = import ./mods.nix {inherit pkgs;};
in {
  services.minecraft-servers = {
    servers.redstone-server = {
      enable = false;
      autoStart = true;
      openFirewall = true;

      # Fabric server for 1.21.11 (same version as bastion-server)
      package = pkgs.fabricServers.fabric-1_21_11;

      jvmOpts = "-Xmx2048M -Xms2048M";

      serverProperties = {
        spawn-protection = 0;
        server-port = 25566;
        gamemode = "creative";
        difficulty = "peaceful";
        view-distance = 32;
        simulation-distance = 10;
        motd = "Redstone Lab";
        allow-cheats = "true";
        enable-command-block = "true";
        enable-lan-visibility = "true";
        level-type = "flat";
        generate-structures = "false";
        generator-settings = "{\"biome\":\"minecraft:desert\",\"layers\":[{\"block\":\"minecraft:bedrock\",\"height\":1},{\"block\":\"minecraft:stone\",\"height\":3},{\"block\":\"minecraft:sandstone\",\"height\":116}],\"structures\":{\"stronghold\":{\"count\":0},\"mineshaft\":{\"count\":0},\"mansion\":{\"count\":0},\"jungle_pyramid\":{\"count\":0},\"desert_pyramid\":{\"count\":0},\"village\":{\"count\":0},\"bastion_remnant\":{\"count\":0},\"fortress\":{\"count\":0},\"endcity\":{\"count\":0},\"buried_treasure\":{\"count\":0},\"ocean_ruin\":{\"count\":0},\"shipwreck\":{\"count\":0},\"swamp_hut\":{\"count\":0},\"nether_fossil\":{\"count\":0},\"ruined_portal\":{\"count\":0}}}";
      };

      # Share the same mods as bastion-server
      files = {
        mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues minecraftMods);
      };
    };
  };
}
