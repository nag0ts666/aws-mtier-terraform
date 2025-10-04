module "network" {
  source = "./modules/network"
}

module "data" {
  source = "./modules/data"
}

module "compute" {
  source = "./modules/compute"
  depends_on = [module.data]

  files_table  = module.data.files_table
  files_bucket = module.data.files_bucket
}

