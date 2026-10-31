# ====== Зоны доступности ======
data "aws_availability_zones" "available" {
  state = "available" # только активные зоны доступности в текущем регионе
}
# ====== VPC ======
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block # диапазон адресов для всей сети
  enable_dns_support   = true # включить DNS разрешение внутри VPC
  enable_dns_hostnames = true # включить DNS имена для инстансов
  tags = merge(
    var.tags, # объединить общие теги
    { Name = "${var.name}-vpc" } # добавить имя VPC с префиксом
  )
}
# ====== Internet Gateway ======
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id # подключить шлюз к созданной VPC
  tags = merge(
    var.tags, # объединить общие теги
    { Name = "${var.name}-igw" } # добавить имя шлюза с префиксом
  )
}
# ====== Публичные подсети ======
resource "aws_subnet" "public" {
  count                   = 2 # создать две публичные подсети
  vpc_id                  = aws_vpc.this.id # подсеть в созданной VPC
  cidr_block              = cidrsubnet(var.cidr_block, 8, count.index) # разделить основной диапазон на подсети
  availability_zone       = data.aws_availability_zones.available.names[count.index] # каждая подсеть в своей зоне доступности
  map_public_ip_on_launch = true # автоматически назначать публичные IP инстансам
  tags = merge(
    var.tags, # объединить общие теги
    {
      Name = "${var.name}-public-${count.index}" # имя подсети с номером
      "kubernetes.io/role/elb"           = "1" # тег для Kubernetes: для балансировщиков нагрузки
      "kubernetes.io/cluster/${var.name}" = "shared" # тег для Kubernetes: подсеть принадлежит кластеру
    }
  )
}
# ====== Route tables ======
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id # таблица маршрутизации для VPC
  route {
    cidr_block = "0.0.0.0/0" # весь трафик (любые адреса)
    gateway_id = aws_internet_gateway.this.id # отправлять через интернет-шлюз
  }
  tags = merge(
    var.tags, # объединить общие теги
    { Name = "${var.name}-public-rt" } # имя таблицы маршрутизации с префиксом
  )
}
# ====== Привязка подсетей к route tables ======
resource "aws_route_table_association" "public" {
  count          = 2 # привязать две подсети к таблице
  subnet_id      = aws_subnet.public[count.index].id # каждая подсеть
  route_table_id = aws_route_table.public.id # к одной таблице маршрутизации
}
