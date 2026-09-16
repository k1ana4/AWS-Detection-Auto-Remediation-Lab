terraform {
  backend "s3" {
    bucket       = "adrl-tfstate-82263be1"
    key          = "lab/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }
}
