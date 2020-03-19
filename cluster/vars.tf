terraform { required_version = ">= 0.12.23" }

### Project Name ###################################################################################

variable "project_name" { default = "your-project" }

### Region #########################################################################################

variable "region" { default = "us-east-2" }


### IAM Setup ######################################################################################

variable "aws_user_profile"    { default = "default" }

variable "credentials"         { default = "<path to your aws credentials file>" }

variable "subnet_count" { default = 2 }

variable "vpc_block" {
        type = map
        default = {
                main = "10.250.0.0/20"
                newbits = 2     # It will depend of subnet size and  must be >= subnet_count
        }
}



variable "nodes_defaults" {
    description = "Default values for target groups as defined by the list of maps."
    type        = map
  
    default = {
      name                 = "eks-work-node" # Name for the eks workers.
      asg_desired_capacity = "1"             # Desired worker capacity in the autoscaling group.
      asg_max_size         = "3"             # Maximum worker capacity in the autoscaling group.
      asg_min_size         = "0"             # Minimum worker capacity in the autoscaling group.
      instance_type        = "t3.small"      # Size of the workers instances.
      key_name             = "eks-key"       # The key name that should be used for the instances in the autoscaling group
      ebs_optimized        = false           # sets whether to use ebs optimization on supported types.
      public_ip            = true            # Associate a public ip address with a worker
    }
}
