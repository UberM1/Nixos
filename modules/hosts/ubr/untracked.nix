{
  config,
  pkgs,
  inputs,
  ...
}: {
  networking.extraHosts = ''
    10.0.0.1 rancher.internal.example
  '';
}
