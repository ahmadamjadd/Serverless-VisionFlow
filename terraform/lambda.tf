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
    lambda_function_arn = aws_lambda_function.lambda_func.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".jpg"
  }

  depends_on = [aws_lambda_permission.with_s3]
}