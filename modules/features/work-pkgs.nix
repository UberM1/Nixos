{pkgs, ...}: {
  home.packages = with pkgs; [
    pscale
    terraform
    kubectl
    kubectl-cnpg
    kubeseal
    kustomize
    kubent
    kubernetes-helm
    argocd
    gcx # grafana cli
    jira-cli-go
  ];
}
