output "ec2_role_name" {
  description = "Name of the IAM role used by EC2 application workloads."
  value       = aws_iam_role.ec2.name
}

output "ec2_role_arn" {
  description = "ARN of the IAM role used by EC2 application workloads."
  value       = aws_iam_role.ec2.arn
}

output "ec2_instance_profile_name" {
  description = "Name of the IAM instance profile associated with the EC2 application role."
  value       = aws_iam_instance_profile.ec2.name
}

output "ec2_instance_profile_arn" {
  description = "ARN of the IAM instance profile associated with the EC2 application role."
  value       = aws_iam_instance_profile.ec2.arn
}