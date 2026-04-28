{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    kubectl
    kubectl-cnpg
    kubeseal
    kustomize
    kubernetes-helm
    vault
  ];
}
