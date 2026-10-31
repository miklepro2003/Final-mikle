# ====== Создание Security Group для кластера ======
resource "aws_security_group" "danit-cluster" {
  name        = "${var.name}-eks-sg" # имя группы (например, mikle-eks-sg)
  description = "Cluster communication with worker nodes" # описание для консоли AWS
  vpc_id      = module.network.vpc_id # id сети берём из модуля network
  # разрешаем весь исходящий трафик (чтобы кластер мог ходить в интернет)
  egress {
    from_port   = 0 # все порты
    to_port     = 0 # все порты
    protocol    = "-1" # все протоколы
    cidr_blocks = ["0.0.0.0/0"] # в любой адрес
  }
  tags = merge(
    var.tags, # объединить общие теги
    { Name = "${var.name}-eks-sg" } # добавить имя группы с префиксом
  )
}
# ====== Узнаём внешний IP-адрес твоего компьютера ======
data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}
# ====== Превращаем IP в CIDR-диапазон ======
locals {
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.response_body)}/32" # /32 значит "ровно один этот IP"
}
# ====== Разрешаем входящие подключения на порт 443 только с твоего IP ======
resource "aws_security_group_rule" "kubeedge-cluster-ingress-workstation-https" {
  cidr_blocks       = [local.workstation-external-cidr] # адрес, откуда разрешён доступ (твой домашний IP)
  description       = "Allow workstation to communicate with the cluster API Server" # описание правила
  from_port         = 443 # начало диапазона (443 — стандарт для HTTPS)
  to_port           = 443 # конец диапазон (диапазон из одного порта 443-443)
  protocol          = "tcp" # протокол связи (TCP — стандарт для веб-трафика)
  security_group_id = aws_security_group.danit-cluster.id # к какому файрволу привязать это правило
  type              = "ingress" # входящий трафик (снаружи внутрь)
}
