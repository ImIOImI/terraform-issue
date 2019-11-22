module "hub-vnet-rg" {
  source = "../modules/hub"
}

module "hub-vnet" {
  source = "../modules/hub"
}

module "hub-gateway-subnet" {
  source = "../modules/hub"
}

module "hub-mgmt" {
  source = "../modules/hub"
}

#Virtual Machine
module "hub-vm" {
  source = "../modules/hub"
}

#SQL Server
module "hub-sql-server" {
  source = "../modules/hub"
}

#SQL Server Pool
module "hub-sql-server-pool" {
  source = "../modules/hub"
}

# # Virtual Network Gateway
# module "hub-vpn-gateway1-pip" {
#   source = "../modules/hub"
# }

# module "hub-vnet-gateway" {
#   source = "../modules/hub"
# }

# module "hub-onprem-conn" {
#   source = "../modules/hub"
# }

# module "onprem-hub-conn" {
#   source = "../modules/hub"
# }
