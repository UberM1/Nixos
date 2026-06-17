{ config, pkgs, lib, ... }:

{
  # Prometheus 
  services.prometheus = {
    enable = true;
    port = 9090;
    stateDir = "prometheus";
    retentionTime = "7d";
    
    globalConfig = {
      scrape_interval = "1m";
    };

    exporters = { 
      node = {
        enable = true;
        port = 9100;
      };
    };


    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [{
          targets = [ "localhost:9100" ];
        }];
      }
      {
        job_name = "minecraft";
        static_configs = [{
          targets = [ "localhost:9940" ];
          labels = {
            server_name = "survival";
          };
        }];
      }
    ];    
  };

  # Grafana 
  services.grafana = {
    enable = true;
    dataDir = "/mnt/data/grafana";
    settings.server = {
      http_addr = "0.0.0.0";
      http_port = 3000;
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [{
        name = "Prometheus";
        type = "prometheus";
        url = "http://localhost:${toString config.services.prometheus.port}";
        isDefault = true;
      }];
    };
  };

  # Resource limits
  systemd.services.prometheus.serviceConfig = {
    MemoryMax = "512M";
    CPUQuota = "50%";
  };

  systemd.services.minecraft-server.serviceConfig = {
    MemoryMax = "6G";
  };

  systemd.services.grafana.serviceConfig = {
    MemoryMax = "256M";
    CPUQuota = "25%";
  };
}
