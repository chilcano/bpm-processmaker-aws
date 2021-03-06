// ======================================================
// Networking configuration   
// ======================================================
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = var.node_name
    Environment = var.node_name
  }
}

resource "aws_internet_gateway" "main_gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = var.node_name
    Environment = var.node_name
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.100.0/24"
  availability_zone = "${var.region}${var.az}"
  map_public_ip_on_launch = true

  tags = {
    Name = var.node_name
    Environment = var.node_name
  }
}

resource "aws_route_table" "gw_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gw.id
  }

  depends_on = [aws_internet_gateway.main_gw]

  tags = {
    Name = var.node_name
    Environment = var.node_name
  }
}

resource "aws_route_table_association" "public_route_table" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.gw_route_table.id
}
// ------------------------------------------------------

// ======================================================
// Security Group and its ingress/egress rules   
// ======================================================
resource "aws_security_group" "sec_group" {
  name = var.node_name
  description = "Allow inbound and outbound traffic"
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = var.node_name
    Environment = var.node_name
  }
}

resource "aws_security_group_rule" "allow_all_from_self" {
  type            = "ingress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  source_security_group_id = aws_security_group.sec_group.id
  security_group_id = aws_security_group.sec_group.id
}

resource "aws_security_group_rule" "allow_ssh_from_admin" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  #cidr_blocks     = split(",", var.developer_cidr_blocks)
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sec_group.id
}

resource "aws_security_group_rule" "allow_https_from_web" {
  type            = "ingress"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = aws_security_group.sec_group.id
}

resource "aws_security_group_rule" "allow_http_from_web" {
  type            = "ingress"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = aws_security_group.sec_group.id
}

resource "aws_security_group_rule" "allow_all_out" {
  type            = "egress"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = aws_security_group.sec_group.id
}
// ------------------------------------------------------

// ======================================================
// IAM configuration      
// ======================================================
resource "aws_iam_role" "ec2_iam_role" {
  name = "${var.node_name}_instance_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "ec2_ebs_policy" {
  name        = "${var.node_name}_instance_policy"
  path        = "/"
  description = "Policy for ${var.node_name} instance to allow dynamic provisioning of EBS persistent volumes"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:CreateVolume",
        "ec2:DeleteVolume",
        "ec2:DescribeInstances",
        "ec2:DescribeRouteTables",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVolumes",
        "ec2:DescribeVolumesModifications",
        "ec2:DescribeVpcs",
        "elasticloadbalancing:DescribeLoadBalancers",
        "ec2:DetachVolume",
        "ec2:ModifyVolume",
        "ec2:CreateTags"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_ebs_policy_att" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = aws_iam_policy.ec2_ebs_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_att" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${var.node_name}_instance_profile"
  role = aws_iam_role.ec2_iam_role.name
}
// ------------------------------------------------------

// ======================================================
// Uploading Bash Script as Template   
// ======================================================

data "template_file" "pre_install_tpl" {
  //template = file("resources/cloudinit/pre_install_tpl.sh")
  template = file("../cloudinit/pre_install_tpl.sh")
}

data "template_cloudinit_config" "my_instance_userdata_cloudinit" {
  base64_encode = true

  part {
    filename     = "install_gui.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.pre_install_tpl.rendered
  }
}
// ------------------------------------------------------

// ======================================================
// EC2 Instances (Remote Environment)
// ======================================================

data "aws_ami" "ami_bitnami_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }

  owners      = [var.ami_owner]
}

resource "aws_instance" "my_instance" {
  ami                     = data.aws_ami.ami_bitnami_linux.id
  instance_type           = var.remote_instance_type
  subnet_id               = aws_subnet.public_subnet.id
  user_data_base64        = data.template_cloudinit_config.my_instance_userdata_cloudinit.rendered
  key_name                = var.ssh_key
  iam_instance_profile    = aws_iam_instance_profile.iam_instance_profile.name
  vpc_security_group_ids  = [aws_security_group.sec_group.id]
  private_ip              = "10.0.100.4"

  depends_on = [aws_internet_gateway.main_gw]

  tags = {
    Name = "${var.node_name}_instance"
    Environment = "${var.node_name}_instance"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}
// ------------------------------------------------------
