module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "database" {
  source = "./modules/database"

  project_name = var.project_name
  environment  = var.environment

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  availability_zone  = module.networking.availability_zones[0]

  db_instance_class = var.db_instance_class
}

module "application" {
  source = "./modules/application"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids

  database_security_group_id = module.database.database_security_group_id

  application_secret_arn  = module.database.application_secret_arn
  application_secret_name = module.database.application_secret_name

  instance_type = var.app_instance_type

  min_size         = var.app_min_size
  desired_capacity = var.app_desired_capacity
  max_size         = var.app_max_size
}
