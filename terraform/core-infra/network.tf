data "aws_availability_zones" "available" {}

module "network-dev" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.4"

  name                        = "dev"
  cidr                        = var.vpc_cidr
  azs                         = data.aws_availability_zones.available.names
  public_subnets              = var.public_subnets
  private_subnets             = var.private_subnets
  enable_dns_hostnames        = true
  enable_ipv6                 = false
  public_subnet_enable_dns64  = false
  private_subnet_enable_dns64 = false

  enable_nat_gateway = true
  single_nat_gateway = false

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1", 
    "tier" = "public"
  }
  

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1", 
    "tier" = "private"
  }
}

resource "plural_service_context" "dev-vpc" {
    name = "plrl/vpc/dev"

    configuration = jsonencode({
        vpc_id          = module.network-dev.vpc_id
        subnet_ids      = concat(module.network-dev.public_subnets, module.network-dev.private_subnets)
        private_subnets = module.network-dev.private_subnets
        public_subnets  = module.network-dev.public_subnets
        vpc_cidr        = var.vpc_cidr
        
        ingress_dns_zone = "dev.drafttests.click"
        
    })
}
