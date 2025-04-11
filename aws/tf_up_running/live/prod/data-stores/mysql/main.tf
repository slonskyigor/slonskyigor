terraform {

  # backend "s3" {
  #
  #   # This backend configuration is filled in automatically at test time by Terratest. If you wish to run this example
  #   # manually, uncomment and fill in the config below.
  #
  #   bucket         = "tf-state-slonsky"
  #   key            = "workspaces-example/terraform.tfstate"
  #   region         = "eu-west-1"
  #   dynamodb_table = "terraform-up-and-running-locks"
  #   encrypt        = true
  #
  # }
}

provider "aws" {
  region = "eu-west-1"
  alias  = "primary"
}

provider "aws" {
  region = "us-west-1"
  alias  = "replica"
}

module "mysql_primary" {
  source = "../../../../modules/data-stores/mysql"

  providers = {
    aws = aws.primary
  }

  db_name     = "prod_db"
  db_username = var.db_username
  db_password = var.db_password

  # Must be enabled to support replication
  backup_retention_period = 1
}

module "mysql_replica" {
  source = "../../../../modules/data-stores/mysql"

  providers = {
    aws = aws.replica
  }

  # Make this a replica of the primary
  replicate_source_db = module.mysql_primary.arn
}