terraform {
     backend "s3" {
         encrypt = true
         bucket = "vulcano-terraform-remote-state"
         dynamodb_table = "vulcano-terraform-state-lock-dynamodb-table"
         region = "us-east-2"
         key = "terraform.tfstate"
     }   
}
