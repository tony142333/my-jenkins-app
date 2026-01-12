# outputs.tf

# Output to Terminal
output "jenkins_url" {
  value = "http://${aws_instance.jenkins_server.public_ip}:8080"
}

output "ssh_login_command" {
  value = "ssh -i tejav.pem ubuntu@${aws_instance.jenkins_server.public_ip}"
}

# Output to a Local File (server_info.txt)
resource "local_file" "server_details" {
  filename = "${path.module}/server_info.txt"
  content  = <<EOT
SERVER DEPLOYMENT DETAILS
=========================
Date Created: ${timestamp()}
Public IP:    ${aws_instance.jenkins_server.public_ip}
Jenkins URL:  http://${aws_instance.jenkins_server.public_ip}:8080
SSH Command:  ssh -i tejav.pem ubuntu@${aws_instance.jenkins_server.public_ip}

Note: The initial admin password was printed in your terminal
during the 'terraform apply' process.
=========================
EOT
}