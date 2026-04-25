# ─────────────────────────────────────────────────────────────
# outputs.tf  —  Values printed after "terraform apply" finishes
# ─────────────────────────────────────────────────────────────
# Outputs are like the "return value" of your infrastructure.
# After Terraform runs, these values are printed to your terminal.

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance — use this to SSH in"
  value       = aws_instance.app_server.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.app_server.public_dns
}

output "ssh_command" {
  description = "Ready-to-use SSH command to connect to your server"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.app_server.public_ip}"
}

output "app_url" {
  description = "URL to access the app once deployed"
  value       = "http://${aws_instance.app_server.public_ip}"
}
