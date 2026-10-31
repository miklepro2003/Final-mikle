# ====== ExternalDNS ======
# в файле курса есть подсказка про установку через ArgoCD, нам она не нужна
module "eks-external-dns" {
  source  = "lablabs/eks-external-dns/aws" # готовый модуль: создаёт роль для ExternalDNS и подключает его к кластеру
  version = "2.1.1" # версия модуля зафиксирована
  cluster_identity_oidc_issuer     = aws_eks_cluster.danit.identity.0.oidc.0.issuer # адрес OIDC кластера, по нему AWS проверяет запросы из кластера
  cluster_identity_oidc_issuer_arn = module.oidc-provider-data.arn # ARN OIDC-провайдера (создан в iam.tf)
  irsa_role_name_prefix            = var.name # начало имени роли: mikle-...
}
