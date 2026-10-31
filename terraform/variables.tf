# ====== Основные настройки кластера и региона ======
variable "name" {} # имя кластера, от него зависят все названия и адреса
variable "tags" {} # общие теги для всех ресурсов

variable "region" {
  description = "aws region"
  default     = "eu-central-1" # регион по умолчанию, где всё создаём
}
# ====== Настройки доступа к AWS и домена ======
variable "iam_profile" {
  description = "Profile of aws creds"
  default     = null # null значит: берём текущие доступы aws cli
}
variable "zone_name" {} # домен, зона которого лежит в Route53
