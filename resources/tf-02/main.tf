locals {
  adj = jsondecode(file("./adjectives.json"))
}

module "network" {
  count            = 1
  source           = "../modules/network"
  required_subnets = 2
  PlaygroundName   = var.PlaygroundName
}

module "workstation" {
  count              = var.deploy_count
  source             = "../modules/instance"
  PlaygroundName     = var.PlaygroundName
  security_group_ids = [module.network.0.allow_all_security_group_id]
  subnet_id          = module.network.0.public_subnets.0
  instance_type      = var.instance_type
  user_data = templatefile(
    "${var.scriptLocation}/02-pm.sh",
    {
      hostname          = "pm"
      username          = "chilcano"
      ssh_pass          = "demodemo"
      gitrepo           = "https://github.com/chilcano/mtls-apps-examples"
    }
  )
  amiName   = "bitnami-processmaker-4.1.21-9-r02-linux-debian-10-x86_64-hvm-ebs-nami"
  amiOwner  = "979382823631"
}
