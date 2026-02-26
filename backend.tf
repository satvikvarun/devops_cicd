terraform {
  backend "s3" {
    bucket         = "satvik-josys"
    key            = "satvik_terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
#comment
