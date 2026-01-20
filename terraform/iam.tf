resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "s3_policy" {
  name        = "lambda_s3_policy"
  description = "Allows lambda to read from source s3 bucket and write to destination s3 bucker"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject", "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = ["${aws_s3_bucket.source.arn}/*", "${aws_s3_bucket.destination.arn}/*"]
      },
    ]
  })
}

resource "aws_iam_policy" "sns_policy" {
  name        = "lambda_sns_policy"
  description = "Allows lambda publish to sns"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:Publish"
        ]
        Effect   = "Allow"
        Resource = aws_sns_topic.sns_topic.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda-s3-attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda-sns-attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.sns_policy.arn
}