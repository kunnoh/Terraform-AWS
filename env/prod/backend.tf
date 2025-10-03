terraform {
  backend "local" {
    path = "../../state/staging/terraform.tfstate"
  }
}