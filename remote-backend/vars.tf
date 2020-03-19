terraform { required_version = ">= 0.12.23" }



### Project Name ###################################################################################

variable "project_name" { default = "vulcano" }



### Region #########################################################################################

variable "region" { default = "us-east-2" }
#variable "region" { default = "us-west-2" }




### IAM Setup ######################################################################################

variable "aws_user_profile"    { default = "default" }

variable "credentials"         { default = "/home/a1/.aws/credentials" }
