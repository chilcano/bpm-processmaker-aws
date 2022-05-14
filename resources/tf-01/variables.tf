variable "node_name" {
  default = "test-2"
  description = "Controls the naming of the AWS resources."
}

variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "ssh_key" {
  type          = string
  description   = "Name of SSH public key you used under AWS > EC2 > Key pairs web console."
  default       = "tmpkey"
}

variable "developer_cidr_blocks" {
  description = "A comma separated list of CIDR blocks to allow SSH connections from."
  default     = "95.169.232.147/0"
}

variable "region" {
  type        = string
  //default = "us-east-1"
  default     = "eu-west-2"
}

variable "az" {
  default = "a"
}

variable "remote_instance_type" {
  type        = string
  //default     = "m1.small"
  default     = "t2.medium"
  description = "EC2 instance type to use for the remotedesktop instance."
}

variable "ami_name_filter" {
  //default = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"          # Ubuntu
  //default = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"           # Ubuntu
  //default = "chilcano/images/hvm-ssd/ubuntu-bionic-18.04-amd64-gui-*"           # Chilcano
  default     = "bitnami-processmaker-4.1.21-9-r02-linux-debian-10-x86_64-hvm-ebs-nami" # Bitnami Processmaker
  description = "AMI Name Filter."
}

variable "ami_owner" {
  //default = "099720109477"     # Ubuntu
  //default = "263455585760"     # Chilcano
  default     = "979382823631"   # bitnami
  description = "AMI Owner." 
}
