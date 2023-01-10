module "network" {
    source="./modules/network"

    cidr_block = var.cidr_block
    external_subnets = var.external_subnets
    internal_subnets = var.internal_subnets
    site_instance = module.instance.site_instance
}

module "instance" {
    source="./modules/instance"

    private_key = var.private_key
    private_key_file = var.private_key_file

    security_group = module.network.security_group
    internal_subnet = module.network.internal_subnet
}