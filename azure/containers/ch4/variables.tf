variable "acr_image" {
  type        = string
  default = "apresstfacr.azurecr.io/httpd"
}

variable "acruser" {
  type        = string
  default = "apresstfacr"
}

variable "acr_server" {
  type        = string
  default = "https://apresstfacr.azurecr.io"
}

variable "acr_password" {
  type        = string
  default     = "password"
}