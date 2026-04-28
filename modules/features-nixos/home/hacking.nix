{pkgs, ...}: {
  home.packages = with pkgs; [
    seclists

    # Networking
    nmap

    thc-hydra

    # hashcat
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
