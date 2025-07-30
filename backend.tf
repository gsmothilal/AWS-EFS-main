terraform {
  backend "s3" {
    bucket  = "terraform-state-pratyushaa-efs-why"
    key     = "efs/dev/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
