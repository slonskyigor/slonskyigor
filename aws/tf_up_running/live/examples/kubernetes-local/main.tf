module "simple_webapp" {
  source = "../../../modules/services/k8s-app"

  name           = "simple-webapp"
  image          = "docker/getting-started"
  replicas       = 2
  container_port = 80
  environment_variables = {
    PROVIDER = "Terraform"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop"
}