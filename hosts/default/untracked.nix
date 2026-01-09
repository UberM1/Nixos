{
  config,
  pkgs,
  inputs,
  ...
}: {
  networking.extraHosts = ''
    10.10.138.2 rancher.qubit.com.ar
  '';
}
