# ====== Установка nginx ingress controller через Helm ======
resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx" # имя установки в helm
  repository       = "https://kubernetes.github.io/ingress-nginx" # откуда скачать chart
  chart            = "ingress-nginx" # название пакета
  version          = "4.10.0" # версия зафиксирована
  namespace        = "kube-system" # ставим в системный namespace
  create_namespace = true # создать, если нет

  # ====== Настройки для создания балансировщика (NLB) и HTTPS ======
  
  set { # прикрепляем SSL-сертификат из acm.tf
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
    value = module.acm.acm_certificate_arn
  }
  
  set { # после расшифровки передаём внутрь обычный HTTP
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"
    value = "http"
  }
  
  set { # применяем сертификат только к порту HTTPS (443)
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-ports"
    value = "https"
  }
  
  set { # делаем балансировщик публичным (доступным из интернета)
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }
  
  set { # выбираем тип балансировщика: Network Load Balancer (NLB)
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  # ====== Куда направлять порты внутри Nginx ======
  
  set { # порт 80 отправляем на HTTP внутри Nginx
    name  = "controller.service.targetPorts.http"
    value = "http"
  }
 
  set {  # порт 443 тоже отправляем на HTTP внутри Nginx (HTTPS уже расшифрован балансировщиком)
    name  = "controller.service.targetPorts.https"
    value = "http"
  }
}
