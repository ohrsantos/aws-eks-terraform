###### MODULE terraform_remote_backend ####################################################################
# This module creates the remote backend

module "terraform_remote_backend" {
    source = "../modules/00-remote-backend/"

    backend_name = "${var.project_name}"
}
