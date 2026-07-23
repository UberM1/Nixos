{
  config,
  pkgs,
  lib,
  ...
}: {
  #
  # Nixarr - Media Server Stack
  # Handles: Jellyfin, *arr stack, qBittorrent, VPN isolation
  #
  nixarr = {
    enable = true;
    mediaDir = "/mnt/data/media";
    stateDir = "/mnt/data/nixarr";

    vpn = {
      enable = true;
      wgConf = "/etc/wireguard/vpn.conf";
    };

    jellyfin = {
      enable = true;
      openFirewall = true;
    };

    radarr = {
      enable = true;
      openFirewall = true;
    };

    sonarr = {
      enable = true;
      openFirewall = true;
    };

    prowlarr = {
      enable = true;
      openFirewall = true;
    };

    bazarr = {
      enable = true;
      openFirewall = true;
    };

    transmission = {
      enable = false;
    };

    qbittorrent = {
      enable = true;
      openFirewall = true;
      vpn.enable = true; # Route through VPN
    };
  };

  #
  # Pi-hole - DNS ad blocker (not part of nixarr)
  #
  services.dnsmasq.enable = false;

  services.pihole-ftl = {
    enable = true;
    lists = [
      {
        url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
        type = "block";
        enabled = true;
        description = "Steven Black's HOSTS";
      }
    ];
    openFirewallDNS = true;
    openFirewallWebserver = true;
    settings = {
      dhcp.active = false;
      dns = {
        interface = "enp0s31f6";
        upstreams = ["1.1.1.1" "1.0.0.1"];
      };
      ntp = {
        ipv4.active = false;
        ipv6.active = false;
        sync.active = false;
      };
    };
  };

  services.pihole-web = {
    enable = true;
    ports = [80];
  };

  # Disable systemd-resolved - Pi-hole handles DNS
  services.resolved.enable = false;
}
