module "vpc" {
  source = "./modules/vpc"
}

module "security" {
  source = "./modules/security"
  vpc_id = module.vpc.vpc_id
}

module "rds" {
  source      = "./modules/rds"
  subnets     = module.vpc.private_db_subnets
  sg_id       = module.security.rds_sg
  db_username = var.db_username
  db_password = var.db_password
}

module "ec2" {
  source               = "./modules/ec2"
  subnets              = module.vpc.private_app_subnets
  frontend_sg          = module.security.frontend_sg
  backend_sg           = module.security.backend_sg
  rds_endpoint         = module.rds.endpoint
  db_username          = var.db_username
  db_password          = var.db_password
  dockerhub_username   = var.dockerhub_username
}

module "alb" {
  source              = "./modules/alb"
  public_subnets      = module.vpc.public_subnets
  alb_sg              = module.security.alb_sg
  vpc_id              = module.vpc.vpc_id
  frontend_instance   = module.ec2.frontend_id
  backend_instance    = module.ec2.backend_id
}
