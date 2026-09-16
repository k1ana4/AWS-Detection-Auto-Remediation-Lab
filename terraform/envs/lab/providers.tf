provider "aws" {
  region              = var.region
  allowed_account_ids = [var.account_id]

  default_tags {
    tags = {
      Project     = "aws-detection-remediation-lab"
      Environment = "lab"
      ManagedBy   = "terraform"
    }
  }
}
