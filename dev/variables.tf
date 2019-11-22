# #Hub vnet variables
variable "prefix-hub-vnet" {
  description = "Prefix for all hub resources in the vnet (dev-hub-vnet)"
}

variable "hub-vnet-location" {
  description = "Location for the hub vnet"
}

variable "hub-vnet-resource-group" {
    description = "Name of the resource group for the hub vnet (dev-hub-vnet-rg)"
}

#Hub nva variables
variable "prefix-hub-nva" {
  description = "Prefix for all hub resources in the network virtual appliance (dev-hub-nva)"
}

variable "vmsize" {
  description = "Size of the VMs"
}

variable "username" {
  description = "Linux VM username"
  default     = "developer"
}

variable "password" {
  description = "Linux VM password"
}

variable "db-user" {
  description = "username for db pools"
  default     = "appian_admin"
}

variable "db-pass" {
  description = "password for db pools"
}

variable "db-server" {
  description = "sql server address prefix (database.windows.net will be added to the end)"
}

variable "db-name" {
  description = "default db name to connect to"
}