provider "aws" {
    region                  = var.region
    shared_credentials_file = var.credentials
    profile                 = var.aws_user_profile
}
