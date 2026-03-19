output "public_subnets" {
  value = local.public_subnets
}
output "private_subnets" {
  value = local.private_subnets
}

output "name_servers" {
  description = "The name servers for your Route53 zone. Copy these to your domain registrar."
  value       = aws_route53_zone.main.name_servers
}

output "frontend_public_ips" {
  description = "Public IPs of the frontend instances"
  value       = [for eip in aws_eip.frontend : eip.public_ip]
}
