terraform {
  # backend "s3" {
  #   bucket         = "my-terraform-state-bucket"
  #   key            = "staging/terraform.tfstate"
  #   region         = "us-east-1"                
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock" # For state locking
    
  #   # Use different AWS profile
  #   # profile = "staging"
  # }

  backend "local" {
    path = "../../state/staging/terraform.tfstate"
  }
}