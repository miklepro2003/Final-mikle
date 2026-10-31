# ====== Группа серверов (Node Group) ======
resource "aws_eks_node_group" "danit" {
  cluster_name    = aws_eks_cluster.danit.name # для какого кластера создаём серверы
  node_group_name = var.name # имя группы (mikle)
  node_role_arn   = aws_iam_role.danit-node.arn # роль (права доступа) для серверов (из iam.tf)
  subnet_ids      = module.network.subnet_ids # подсети, где запускать серверы (из модуля network)
  # ====== Настройки количества серверов ======
  scaling_config {
    desired_size = 1 # сколько серверов нужно сейчас
    max_size     = 1 # максимум серверов
    min_size     = 1 # минимум серверов
  }
  # ====== Тип сервера ======
  instance_types = ["c7i-flex.large"]  # c7i-flex.large входит в бесплатный тариф AWS

  # ====== Метки на сервере ======
  labels = {
    "node-type" : "tests" # по этой метке Kubernetes понимает, какие поды сюда можно ставить
  }
  # политики должны прикрепиться к роли ДО создания серверов
  depends_on = [
    aws_iam_role_policy_attachment.kubeedge-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.kubeedge-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.kubeedge-node-AmazonEC2ContainerRegistryReadOnly,
  ]
  tags = merge(
    var.tags, # объединить общие теги
    { Name = "${var.name}-node-group" } # имя группы в тегах
  )
}