output "jenkins_url" {
  description = "The public URL to access the Jenkins Web UI"
  value       = "http://${aws_instance.jenkins_server.public_ip}:8080"
}

output "instance_public_ip" {
  description = "The public IP address of the Jenkins server"
  value       = aws_instance.jenkins_server.public_ip
}