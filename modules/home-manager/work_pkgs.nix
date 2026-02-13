{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    # connection tools
    freerdp
    pscale
    postgresql
    vault

    # k8s management
    kubectl
    kubectl-cnpg
    kubeseal
    kustomize
    kubernetes-helm
  ];
}
