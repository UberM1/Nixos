{pkgs, ...}: {
  imports = [
    ./untracked.nix
    ../../features-nixos/system/shell-tools.nix
    ../../features-nixos/system/privileged.nix
    ../../features-nixos/system/dolphin.nix
    ../../features-nixos/system/hyprland.nix
    ../../features-nixos/system/nvidia.nix
  ];

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = false;

  # DDC/CI for monitor brightness control
  boot.kernelModules = ["i2c-dev"];
  hardware.i2c.enable = true;

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    nameservers = ["1.1.1.1"];
  };

  # Timezone
  time.timeZone = "America/Argentina/Buenos_Aires";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_AR.UTF-8";
    LC_IDENTIFICATION = "es_AR.UTF-8";
    LC_MEASUREMENT = "es_AR.UTF-8";
    LC_MONETARY = "es_AR.UTF-8";
    LC_NAME = "es_AR.UTF-8";
    LC_NUMERIC = "es_AR.UTF-8";
    LC_PAPER = "es_AR.UTF-8";
    LC_TELEPHONE = "es_AR.UTF-8";
    LC_TIME = "es_AR.UTF-8";
  };

  # Keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.blueman.enable = true;

  # User
  users.users.ubr = {
    isNormalUser = true;
    description = "ubr";
    extraGroups = ["video" "audio" "disk" "storage" "networkmanager" "wheel" "i2c"];
    shell = pkgs.zsh;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    kitty
    vim
    git
    ddcutil
    foot
    glfw
    glib
    gobject-introspection
    gsettings-desktop-schemas
    shared-mime-info
  ];

  # Display manager
  services.displayManager.ly.enable = true;

  # XDG
  xdg = {
    portal.enable = true;
    portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
    mime.enable = true;
    menus.enable = true;
  };

  # Services
  services.udisks2.enable = true;
  services.upower.enable = true;

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  programs.zsh.enable = true;

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    KITTY_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    GI_TYPELIB_PATH = "${pkgs.glib.out}/lib/girepository-1.0:${pkgs.gobject-introspection}/lib/girepository-1.0";
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  system.stateVersion = "25.11";

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    warn-dirty = false;
    auto-optimise-store = true;
  };

  nixpkgs.config.allowUnfree = true;
}
