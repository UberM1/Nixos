{pkgs, ...}: {
  home.packages = with pkgs; [
    pscale
    terraform
    kubectl
    kubectl-cnpg
    kubeseal
    kustomize
    kubernetes-helm
  ];
}
