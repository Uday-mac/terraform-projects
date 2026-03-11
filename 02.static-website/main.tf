resource "aws_s3_bucket" "static-www" {
  bucket = var.bucket

  tags = {
    Name = "static-project"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket                  = aws_s3_bucket.static-www.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_cloudfront_origin_access_control" "demo-oac" {
  name                              = "cf-oac"
  description                       = "allows access for CF to access static website in s3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket_policy" "allow_cf" {
  bucket     = aws_s3_bucket.static-www.id
  depends_on = [aws_s3_bucket_public_access_block.example]
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowCloudFront",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "cloudfront.amazonaws.com"
          },
          "Action" : [
            "s3:GetObject",
            "s3:ListBucket"
          ],
          "Resource" : [
            "${aws_s3_bucket.static-www.arn}",
            "${aws_s3_bucket.static-www.arn}/*"
          ],
          "Condition" : {
            "StringEquals" : {
              "AWS:SourceArn" : "${aws_cloudfront_distribution.s3_distribution.arn}"
            }
          }
        }
      ]
    }
  )
}

resource "aws_s3_object" "object" {
  for_each = fileset("${path.module}/www", "**/*")
  bucket   = aws_s3_bucket.static-www.bucket
  key      = each.value
  source   = "${path.module}/www,${each.value}"
  etag     = filemd5("${path.module}/www/${each.value}")
  content_type = lookup(
    {
      ".css"  = "text/css"
      ".js"   = "application/javascript"
      ".html" = "text/html"
    },
    regex("\\.[^.]+$", each.value),
    "binary/octet-stream"
  )
}

