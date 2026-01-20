resource "aws_s3_bucket" "source" {
  bucket = var.source_bucket_name
}

resource "aws_s3_bucket" "destination" {
  bucket = var.destination_bucket_name
}

resource "aws_s3_bucket" "zipFile" {
  bucket = var.layer_bucket_name
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.zipFile.id
  key    = "opencv-layer.zip"
  source = "../opencv_layer/opencv_layer.zip"
  etag   = filemd5("../opencv_layer/opencv_layer.zip")
}