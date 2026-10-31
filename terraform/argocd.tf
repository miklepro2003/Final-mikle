# ====== Установка ArgoCD через Helm ======
resource "helm_release" "argocd" { # ставим программу через Helm (менеджер пакетов для Kubernetes)
  name             = "argocd"                     # имя этой установки в Helm
  repository       = "https://argoproj.github.io/argo-helm" # сайт, откуда скачиваем готовый пакет (chart)
  chart            = "argo-cd"                              # название пакета на этом сайте
  version          = "9.5.11"                          # версия пакета, зафиксирована, чтобы установка не менялась сама
  namespace        = "argocd"                    # в какой namespace кластера ставим
  create_namespace = true                      # создать этот namespace, если его ещё нет
 
 # ====== Настройки chart (values) ======
  # дальше идёт текст настроек в формате YAML, он заканчивается строкой EOT
  values = [<<-EOT
    global:
      # общие настройки, которые используют все части ArgoCD
      domain: argocd.${local.domain_name}
      # адрес, по которому будем открывать ArgoCD: argocd.mikle.mikle-final.pp.ua
    configs:
      # настройки работы самой программы ArgoCD
      params:
        # параметры запуска ArgoCD
        server.insecure: true
        # сервер принимает обычный http: HTTPS уже расшифровал балансировщик, а без этого будет бесконечный редирект
    server:
      # настройки сервера ArgoCD: это его веб-интерфейс и API
      ingress:
        # настройки входа: какой внешний трафик пускать внутрь кластера на сервер ArgoCD
        enabled: true
        # создать это правило входа (Ingress): запросы на адрес argocd... отправлять на сервер ArgoCD
        ingressClassName: nginx
        # кто пускает трафик по этому правилу: nginx ingress controller, который мы поставили в Части 2
  EOT
  ]

  # ====== Порядок установки ======
  # ставим ArgoCD только после nginx ingress controller, иначе создание Ingress упадёт с ошибкой
  depends_on = [helm_release.nginx_ingress]
}