# ====== Ищем нашу зону в Route53 ======
data "aws_route53_zone" "zone" {
  name         = var.zone_name # имя зоны: mikle-final.pp.ua
  private_zone = false # ищем публичную зону, а не внутреннюю
}
# ====== Собираем имя домена ======
locals {
  domain_name = "${var.name}.${var.zone_name}" # склеиваем имя кластера и зону: mikle.mikle-final.pp.ua
}
# ====== Заказываем сертификат ======
module "acm" {
  source  = "terraform-aws-modules/acm/aws" # готовый модуль из реестра Terraform
  version = "~> 3.0" # подойдёт любая версия 3.x
  domain_name = local.domain_name # основное имя в сертификате
  zone_id     = data.aws_route53_zone.zone.zone_id # в какой зоне создать записи для подтверждения
  subject_alternative_names = [
    "*.${local.domain_name}", # все поддомены: argocd.mikle..., app.mikle...
  ]
  wait_for_validation = true # ждать, пока AWS подтвердит сертификат
  tags = merge(
    var.tags, # общие теги
    { Name = "${var.name}-eks" } # имя сертификата в тегах
  )
}
