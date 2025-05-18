terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_s3_bucket" "gha_security_hosting_demo" {
  bucket = "gha-security-hosting-demo-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# 静的ウェブサイトホスティングの設定
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.gha_security_hosting_demo.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# バケットポリシーを設定してパブリックアクセスを許可
resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.gha_security_hosting_demo.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.gha_security_hosting_demo.arn}/*"
      }
    ]
  })
}

# パブリックアクセスブロックを解除
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.gha_security_hosting_demo.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
