terraform {

  backend "s3" {

    # This backend configuration is filled in automatically at test time by Terratest. If you wish to run this example
    # manually, uncomment and fill in the config below.

    bucket         = "tf-state-slonsky"
    key            = "workspaces-example/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true

  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_db_instance" "example" {
  identifier_prefix   = "terraform-up-and-running"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t3.micro"
  skip_final_snapshot = true

  db_name = var.db_name

  username = var.db_username
  password = var.db_password
}
