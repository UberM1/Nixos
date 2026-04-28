{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    rbenv
    libyaml
    readline
    libffi
    openssl
  ];
}
