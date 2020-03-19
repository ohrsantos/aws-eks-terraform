# terraform state file setup
resource "aws_s3_bucket" "terraform-remote-state-s3-bucket" {
    bucket = "${var.backend_name}-terraform-remote-state"
    
    acl    = "private"
 
    # Prevent accidental deletion of this S3 bucket
    lifecycle {
      prevent_destroy = false
    }
 
    # Enable versioning so we can see the full revision history of our state files
    versioning {
      enabled = false
    }
  
    # Enable server-side encryption by default
    server_side_encryption_configuration {
      rule {
          apply_server_side_encryption_by_default {
              sse_algorithm = "AES256"
        }
      }
    }

    tags = {
      Name = "S3 Remote Terraform State Store"
    }      
}


resource "aws_dynamodb_table" "terraform-state-lock-dynamodb-table" {
  name = "${var.backend_name}-terraform-state-lock-dynamodb-table"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
 
  lifecycle {
    prevent_destroy = false
  }

  attribute {
    name = "LockID"
    type = "S"
  }
 
  tags = {
    Name = "DynamoDB Terraform State Lock Table"
  }
}
