{config, ...}: {
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    powerManagement = {
      enable = true;
      finegrained = false;
    };
    open = true;
    nvidiaSettings = true;
    nvidiaPersistenced = true;
    modesetting.enable = true;
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
