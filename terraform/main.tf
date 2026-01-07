terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "source" {
  bucket = "image-resizer-source-908"
}

resource "aws_s3_bucket" "destination" {
  bucket = "image-resizer-destination-908"
}

resource "aws_sns_topic" "sns_topic" {
  name = "image-resizer-topic"
}


resource "aws_sns_topic_subscription" "sns_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = "muhammadahmadamjad0@gmail.com"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
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

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject","s3:PutObject"
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

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
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


resource "aws_s3_bucket" "zipFile" {
  bucket = "image-resizer-zipfile-908"
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.zipFile.id
  key    = "opencv-layer.zip"
  source = "../opencv_layer/opencv_layer.zip"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("../opencv_layer/opencv_layer.zip")
}

resource "aws_lambda_layer_version" "zipFileLayer" {
  s3_bucket = aws_s3_object.object.bucket
  s3_key    = aws_s3_object.object.key

  layer_name = "ImageResizerOpenCVLayer"

  compatible_runtimes      = ["python3.12"]
  compatible_architectures = ["x86_64"]
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../LambdaCode/imageresizer.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "lambda_func" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "imageResizer_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "imageresizer.lambda_handler"
  runtime       = "python3.12"

  layers = [aws_lambda_layer_version.zipFileLayer.arn]
}

resource "aws_lambda_permission" "with_s3" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_func.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.source.id

  lambda_function {
    # Use 'lambda_function_arn' instead of 'topic_arn'
    lambda_function_arn = aws_lambda_function.lambda_func.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".jpg"
  }

  # This 'depends_on' ensures S3 doesn't try to create the trigger 
  # before the Lambda has permission to hear it!
  depends_on = [aws_lambda_permission.with_s3]
}