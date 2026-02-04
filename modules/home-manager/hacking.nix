{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    seclists # dicts

    # Networking
    nmap

    thc-hydra # login brute forcing

    # hashcat <3
    hashcat
    hashcat-utils
    rar2hashcat
    _7z2hashcat
    zip2hashcat

    sqlmap

    # custom wordlist generators
    cewl
    crunch
  ];
}
