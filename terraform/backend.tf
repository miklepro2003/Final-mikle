terraform {
  backend "s3" {
    bucket         = "final-mikle-tfstate-miklepro" # имя бакета
    key            = "eks/terraform.tfstate"        # путь к файлу state внутри бакета
    encrypt        = true                           # шифровать файл state в бакете
    dynamodb_table = "lock-tf-eks" # название таблицы для блокировки, чтобы 2 запуска не писали state одновременно
    # ключ таблицы называется LockID (регистр важен)
    # регион и профиль сюда не пишем, они передаются при terraform init через -backend-config
    # region =
    # profile =
  }
}
