terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "alb" {
  source = "../../../modules/networking/alb"

  alb_name   = var.alb_name

  subnet_ids = data.aws_subnets.default.ids
}
