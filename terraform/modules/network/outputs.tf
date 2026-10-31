output "vpc_id" {
  value = aws_vpc.this.id # id сети, нужен для security group
}
output "subnet_ids" {
  value = aws_subnet.public[*].id # список id обеих подсетей, нужен кластеру и нодам
}
