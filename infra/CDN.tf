resource "aws_cloudfront_distribution" "terraform_cloudfront_distribution" {
  
  enabled = true
  default_root_object = "index.html"
  

  origin {
    origin_id                = "${var.frontend_s3_bucket_name}-origin"
    domain_name              = aws_s3_bucket.frontend_s3_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }


  origin {
    domain_name = "${aws_lb.terraform_load_balancer.dns_name}"
    origin_id   = "ALB-${aws_lb.terraform_load_balancer.id}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" 
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }



  default_cache_behavior {
    target_origin_id = "${var.frontend_s3_bucket_name}-origin"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]

   cache_policy_id = aws_cloudfront_cache_policy.cache_policty.id

    viewer_protocol_policy = "allow-all"
  }

  # Cache behavior for /login
  ordered_cache_behavior {
    path_pattern     = "/login"
    allowed_methods  = ["GET", "HEAD", "POST", "PUT", "PATCH", "OPTIONS", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ALB-${aws_lb.terraform_load_balancer.id}"
    cache_policy_id = aws_cloudfront_cache_policy.cache_policty.id
    viewer_protocol_policy = "allow-all"
  }

  # Cache behavior for /api/*
  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["GET", "HEAD", "POST", "PUT", "PATCH", "OPTIONS", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ALB-${aws_lb.terraform_load_balancer.id}"
   cache_policy_id = aws_cloudfront_cache_policy.cache_policty.id
    viewer_protocol_policy = "allow-all"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_200"
  
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_s3_bucket_policy" "S3-frontend-bucket-policy-allow-cloufront" {
  bucket = aws_s3_bucket.frontend_s3_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal ={Service="cloudfront.amazonaws.com"}
        Condition = {
        StringEquals = {
          "AWS:SourceArn" = "${aws_cloudfront_distribution.terraform_cloudfront_distribution.arn}"
        }
      }
        Action   = ["s3:GetObject"],
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.frontend_s3_bucket.arn}/*"
      },
    ]
  })
}



resource "aws_cloudfront_cache_policy" "cache_policty" {
  name        = "cache_policty"
  comment     = "test comment"
  default_ttl = 2
  max_ttl     = 5
  min_ttl     = 1
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "whitelist"
      cookies {
        items = ["JSESSIONID", "SESSION"]
      }
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}