# ====== Главный объект: сам EKS-кластер ======
resource "aws_eks_cluster" "danit" {
  name     = var.name # имя кластера (mikle)
  role_arn = aws_iam_role.cluster.arn # роль, под которой кластер работает в AWS
  vpc_config {
    security_group_ids = [aws_security_group.danit-cluster.id] # наш файрвол (из sg.tf)
    subnet_ids         = module.network.subnet_ids # наши подсети (из модуля network)
  }

  depends_on = [ # роли и политики должны прикрепиться ДО создания кластера
    aws_iam_role_policy_attachment.kubeedge-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.kubeedge-cluster-AmazonEKSVPCResourceController,
  ]

  tags = merge(
    var.tags, # объединить общие теги
    { Name = "${var.name}" } # добавить имя кластера
  )
}
# ====== Токен доступа к кластеру ======
# нужен, чтобы Terraform и провайдеры (Kubernetes, Helm) могли зайти в кластер
data "aws_eks_cluster_auth" "danit" {
  name = aws_eks_cluster.danit.name # получаем токен для кластера
}

# ====== Автоматический выбор версии CoreDNS ======
# Terraform сам спросит у AWS самую свежую версию для твоей версии Kubernetes
data "aws_eks_addon_version" "coredns" {
  addon_name         = "coredns"
  kubernetes_version = aws_eks_cluster.danit.version
  most_recent        = true
}
# ====== Аддон CoreDNS (внутренний DNS кластера) ======
resource "aws_eks_addon" "coredns" {
  cluster_name                = var.name
  addon_name                  = "coredns"
  addon_version               = data.aws_eks_addon_version.coredns.version # версия берется автоматически
  resolve_conflicts_on_create = "OVERWRITE"
  # CoreDNS ставим только после создания ноды, иначе ему негде запуститься
  depends_on = [aws_eks_node_group.danit]
}