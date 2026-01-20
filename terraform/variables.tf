variable "aws_region" {
  description = "AWS region for resources"
  default     = "ap-south-1"
}

variable "notification_email" {
  description = "Email address for SNS notifications"
  default     = "muhammadahmadamjad0@gmail.com" //those using my project must add their email here
}

variable "source_bucket_name" {
  description = "Name of the source S3 bucket"
  default     = "image-resizer-source-908"
}

variable "destination_bucket_name" {
  description = "Name of the destination S3 bucket"
  default     = "image-resizer-destination-908"
}

variable "layer_bucket_name" {
  description = "Name of the bucket storing the Lambda Layer zip"
  default     = "image-resizer-zipfile-908"
}