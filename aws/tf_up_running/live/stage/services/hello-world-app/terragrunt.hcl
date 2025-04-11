terraform {
  source = "git::https://github.com/slonskyigor/modules.git//modules/services/hello-world-app?ref=0.0.11"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "mysql" {
  config_path = "../../data-stores/mysql"
}

inputs = {
  environment = "stage"
  ami         = "ami-07721f34af7d85e8f"

  min_size = 2
  max_size = 2

  enable_autoscaling = false

  mysql_config = dependency.mysql.outputs
}
