resource "azurerm_resource_group" "hub-vnet-rg" {
  name     = var.hub-vnet-resource-group
  location = var.hub-vnet-location
}

resource "azurerm_virtual_network" "hub-vnet" {
  name                = "${var.prefix-hub-vnet}-vnet"
  location            = azurerm_resource_group.hub-vnet-rg.location
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "hub-spoke"
  }
}

resource "azurerm_subnet" "hub-gateway-subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefix       = "10.0.255.224/27"
}

resource "azurerm_subnet" "hub-mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefix       = "10.0.0.64/27"
}

resource "azurerm_subnet" "hub-dmz" {
  name                 = "dmz"
  resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefix       = "10.0.0.32/27"
}

resource "azurerm_network_interface" "hub-nic" {
  name                 = "${var.prefix-hub-vnet}-nic"
  location             = azurerm_resource_group.hub-vnet-rg.location
  resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = var.prefix-hub-vnet
    subnet_id                     = azurerm_subnet.hub-mgmt.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = var.prefix-hub-vnet
  }
}

#Virtual Machine
resource "azurerm_virtual_machine" "hub-vm" {
  name                  = "${var.prefix-hub-vnet}-vm"
  location              = azurerm_resource_group.hub-vnet-rg.location
  resource_group_name   = azurerm_resource_group.hub-vnet-rg.name
  network_interface_ids = [azurerm_network_interface.hub-nic.id]
  vm_size               = var.vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix-hub-vnet}-vm"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = var.prefix-hub-vnet
  }
}

#SQL Server
resource "azurerm_sql_server" "hub-sql-server" {
  name                         = "apn-dev-sql-server" # NOTE: needs to be globally unique
  resource_group_name          = azurerm_resource_group.hub-vnet-rg.name
  location                     = azurerm_resource_group.hub-vnet-rg.location
  version                      = "12.0"
  administrator_login          = var.db-user
  administrator_login_password = var.db-pass
}

#SQL Server Pool
resource "azurerm_sql_elasticpool" "hub-sql-server-pool" {
  name                = "hub-sql-server-pool"
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name
  location            = azurerm_resource_group.hub-vnet-rg.location
  server_name         = azurerm_sql_server.hub-sql-server.name
  edition             = "Basic"
  dtu                 = 50
  db_dtu_min          = 0
  db_dtu_max          = 5
  pool_size           = 5000
}

resource "azurerm_sql_firewall_rule" "test" {
  name                = "Troy at Home"
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name
  server_name         = azurerm_sql_server.hub-sql-server.name
  start_ip_address    = "72.198.116.138"
  end_ip_address      = "72.198.116.138"
}

resource "azurerm_sql_firewall_rule" "class-a-rule" {
  name                = "Class A Private Network"
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name
  server_name         = azurerm_sql_elasticpool.hub-sql-server-pool.name
  start_ip_address    = "10.0.0.0"
  end_ip_address      = "10.255.255.255"
}

resource "azurerm_sql_firewall_rule" "class-b-rule" {
  name                = "Class B Private Network"
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name
  server_name         = azurerm_sql_elasticpool.hub-sql-server-pool.name
  start_ip_address    = "172.16.0.0"
  end_ip_address      = "172.31.255.255"
}

resource "azurerm_sql_firewall_rule" "class-c-rule" {
  name                = "Class B Private Network"
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name
  server_name         = azurerm_sql_elasticpool.hub-sql-server-pool.name
  start_ip_address    = "192.168.0.0"
  end_ip_address      = "192.168.255.255"
}

# Virtual Network Gateway
# resource "azurerm_public_ip" "hub-vpn-gateway1-pip" {
#   name                = "hub-vpn-gateway1-pip"
#   location            = azurerm_resource_group.hub-vnet-rg.location
#   resource_group_name = azurerm_resource_group.hub-vnet-rg.name

#   allocation_method = "Dynamic"
# }

# resource "azurerm_virtual_network_gateway" "hub-vnet-gateway" {
#   name                = "hub-vpn-gateway1"
#   location            = azurerm_resource_group.hub-vnet-rg.location
#   resource_group_name = azurerm_resource_group.hub-vnet-rg.name

#   type     = "Vpn"
#   vpn_type = "RouteBased"

#   active_active = false
#   enable_bgp    = false
#   sku           = "VpnGw1"

#   ip_configuration {
#     name                          = "vnetGatewayConfig"
#     public_ip_address_id          = azurerm_public_ip.hub-vpn-gateway1-pip.id
#     private_ip_address_allocation = "Dynamic"
#     subnet_id                     = azurerm_subnet.hub-gateway-subnet.id
#   }
#   depends_on = ["azurerm_public_ip.hub-vpn-gateway1-pip"]
# }

# resource "azurerm_virtual_network_gateway_connection" "hub-onprem-conn" {
#   name                = "hub-onprem-conn"
#   location            = azurerm_resource_group.hub-vnet-rg.location
#   resource_group_name = azurerm_resource_group.hub-vnet-rg.name

#   type           = "Vnet2Vnet"
#   routing_weight = 1

#   virtual_network_gateway_id      = azurerm_virtual_network_gateway.hub-vnet-gateway.id
#   peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.onprem-vpn-gateway.id

#   shared_key = local.shared-key
# }

# resource "azurerm_virtual_network_gateway_connection" "onprem-hub-conn" {
#   name                = "onprem-hub-conn"
#   location            = azurerm_resource_group.onprem-vnet-rg.location
#   resource_group_name = azurerm_resource_group.onprem-vnet-rg.name
#   type                            = "Vnet2Vnet"
#   routing_weight = 1
#   virtual_network_gateway_id      = azurerm_virtual_network_gateway.onprem-vpn-gateway.id
#   peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.hub-vnet-gateway.id

#   shared_key = local.shared-key
# }
