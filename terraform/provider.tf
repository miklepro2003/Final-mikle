# ====== Подключение к AWS ======
provider "aws" {
  region  = var.region       # в каком регионе всё создаём
  profile = var.iam_profile  # какими доступами пользоваться (null значит текущие доступы aws cli)
}

# ====== Подключение к Kubernetes ======
provider "kubernetes" {
  host                   = aws_eks_cluster.danit.endpoint                                    # адрес api-сервера кластера
  cluster_ca_certificate = base64decode(aws_eks_cluster.danit.certificate_authority.0.data)  # сертификат кластера, чтобы терраформ доверял его адресу
  token                  = data.aws_eks_cluster_auth.danit.token                             # временный токен-пропуск (берётся из eks-cluster.tf)
}

# ====== Версия провайдера Helm ======
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm" # откуда скачать плагин
      version = "= 2.12.1"       # ровно эта версия, без обновлений (знак = значит точно)
    }
  }
}

# ====== Подключение к Helm ======
provider "helm" {
  kubernetes {                                                                               # helm должен знать, в какой кластер ставить
    host                   = aws_eks_cluster.danit.endpoint            # адрес api-сервера кластера
    cluster_ca_certificate = base64decode(aws_eks_cluster.danit.certificate_authority.0.data) # сертификат кластера
    token                  = data.aws_eks_cluster_auth.danit.token     # тот же временный токен
  }
}

# ====== Список зон доступности ======
data "aws_availability_zones" "available" {} # в нашем проекте не используется, зоны берёт модуль network
