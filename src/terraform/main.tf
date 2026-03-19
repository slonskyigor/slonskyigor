/*
resource "aws_route53_zone" "main" {
  name = var.domain_name
}
*/

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "temp_key"
  public_key = tls_private_key.main.public_key_openssh
}

resource "local_file" "ssh_key" {
  content  = tls_private_key.main.private_key_pem
  filename = "${path.module}/temp_key.pem"
}


# setup a resource group
resource "aws_resourcegroups_group" "main" {
  name = "${var.application_name}-${var.environment_name}"

  resource_query {
    query = jsonencode(
      {
        ResourceTypeFilters = [
          "AWS::AllSupported"
        ]
        TagFilters = [
          {
            Key    = "application"
            Values = [var.application_name]
          },
          {
            Key    = "environment"
            Values = [var.environment_name]
          }
        ]
      }
    )
  }
}