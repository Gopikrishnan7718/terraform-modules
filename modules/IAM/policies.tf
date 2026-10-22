resource "aws_iam_role_policy" "ec2" {
  name = "${var.name}-ec2-policy"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowArtifactBucketAccess"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]

        Resource = "${var.artifact_bucket_arn}/*"
      },
      {
        Sid    = "AllowArtifactBucketListing"
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = var.artifact_bucket_arn
      }
    ]
  })
}