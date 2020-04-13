provider "panos" {}

module "networking" {
  source = "./modules/networking"

  template = var.template
  stack    = var.stack
}

module "policies" {
  source = "./modules/policies"

  device_group = var.device_group

  zone_untrust = module.networking.zone_untrust
  zone_web     = module.networking.zone_web
  zone_db      = module.networking.zone_db

  interface_untrust = module.networking.interface_untrust
  interface_web     = module.networking.interface_web
  interface_db      = module.networking.interface_db
}

resource "null_resource" "commit_panorama" {
  provisioner "local-exec" {
    command = "go run commit.go"
  }
  depends_on = [
    module.policies.security_rule_group,
    module.policies.nat_rule_group
  ]
}
