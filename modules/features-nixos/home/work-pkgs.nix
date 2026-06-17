{pkgs, ...}: {
  home.packages = with pkgs; [
    # connection tools
    freerdp
    pscale
    postgresql
    vault
    sqlcmd

    terraform
    python3

    # k8s management
    kubectl
    kubectl-cnpg
    kubeseal
    kustomize
    kubernetes-helm
  ];
}
