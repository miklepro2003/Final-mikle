variable "name" {
  description = "имя кластера, используется в именах ресурсов и в тегах подсетей"
}
variable "tags" {
  description = "общие теги для всех ресурсов"
  default     = {}
}
variable "cidr_block" {
  description = "диапазон адресов всей сети"
  default     = "10.0.0.0/16"
}
