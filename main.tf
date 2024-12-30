provider "aws" {
  region = "us-east-1"
}

data "aws_secretsmanager_secret" "db_password" {
  name = "db-password"
}

data "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}

output "db_password" {
  value     = data.aws_secretsmanager_secret_version.db_password_version.secret_string
  sensitive = true
}

resource "aws_instance" "example" {
  ami           = "ami-01816d07b1128cd2d"
  instance_type = "t2.micro"

  user_data = <<-EOT
              #!/bin/bash
              echo "DB_PASSWORD=${data.aws_secretsmanager_secret_version.db_password_version.secret_string}" > /etc/db_credentials
              chmod 600 /etc/db_credentials
              EOT

  tags = {
    Name = "ExampleInstance"
  }
}
