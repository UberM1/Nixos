{pkgs, ...}: {
  stylix = {
    enable = true;
    autoEnable = true;
    enableReleaseChecks = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyodark.yaml";
    image = ../../wallpapers/nord/ign-legendary.png;

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      serif = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sizes = {
        terminal = 11;
        applications = 11;
        desktop = 11;
      };
    };

    cursor = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-dark";
      size = 24;
    };

    opacity = {
      terminal = 0.85;
    };

    targets = {
      firefox = {
        enable = true;
        profileNames = ["default"];
      };
      kitty.enable = true;
      rofi.enable = true;
      gtk.enable = true;
      hyprland.enable = true;
      nixvim.enable = true;
      noctalia-shell.enable = true;
      starship.enable = true;
      obsidian.enable = true;
      bat.enable = true;
      lazygit.enable = true;
    };
  };
}
