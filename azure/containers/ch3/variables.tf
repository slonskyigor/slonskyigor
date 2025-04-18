variable "acr_image" {
  type    = string
  default = "nginx:v1"
}

variable "acruser" {
  type    = string
  default = "apresstfacr"
}

variable "acr_server" {
  type    = string
  default = "https://apresstfacr.azurecr.io"
}

variable "acr_password" {
  type = string
  default = "0LgzoqA4HGCzIPlWnkTXteCQnyj1hCSbG6MWCfqYFn+ACRD6lojs"
}
