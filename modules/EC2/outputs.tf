output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance."
  value       = aws_instance.this.arn
}

output "private_ip" {
  description = "Private IPv4 address of the EC2 instance."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IPv4 address of the EC2 instance, if assigned."
  value       = aws_instance.this.public_ip
}

output "private_dns" {
  description = "Private DNS name of the EC2 instance."
  value       = aws_instance.this.private_dns
}

output "availability_zone" {
  description = "Availability Zone in which the EC2 instance is running."
  value       = aws_instance.this.availability_zone
}

output "instance_state" {
  description = "Current state of the EC2 instance."
  value       = aws_instance.this.instance_state
}