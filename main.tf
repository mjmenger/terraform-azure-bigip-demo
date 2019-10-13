resource "random_id" "id" {
    byte_length = 2
}

resource "azurerm_resource_group" "main" {
  name     = format("%s-resourcegroup-%s", var.prefix, random_id.id.hex)
  location = var.region
}

#
# Create the demo network
#
module "network" {
    source              = "Azure/network/azurerm"
    version             = "2.0.0"
    vnet_name           = format("%s-vnet-%s", var.prefix, random_id.id.hex)
    resource_group_name = format("%s-resourcegroup-%s", var.prefix, random_id.id.hex)
    location            = var.region
    address_space       = var.cidr
    subnet_prefixes     = concat(
        [for num in range(length(var.azs)): cidrsubnet(var.cidr, 8, num)],
        [for num in range(length(var.azs)): cidrsubnet(var.cidr, 8, num + 10)],
    )
    subnet_names        = concat(
        [for num in range(length(var.azs)): format("%s-privatesubnet-%s",var.prefix,num)],
        [for num in range(length(var.azs)): format("%s-publicsubnet-%s",var.prefix,num + 10)]
    )

    tags                = {
                            environment = var.environment
                            costcenter  = "sales"
                            terraform    = "true"
                          }
}

resource "azurerm_public_ip" "test" {
  name                = "acceptanceTestPublicIp1"
  location            = var.region
  resource_group_name = "${azurerm_resource_group.main.name}"
  allocation_method   = "Static"

  tags = {
    environment = var.environment
    terraform   = "true"
  }
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic-${random_id.id.hex}"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${module.network.vnet_subnets[0]}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.test.id}"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

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
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}


#
# Create the demo NGINX app
#
# module "nginx-demo-app" {
#   source  = "github.com/mjmenger/terraform-azure-nginx-demo-app"
#   #version = "0.1.2"

#   prefix = format(
#     "%s-%s",
#     var.prefix,
#     random_id.id.hex
#   )
#   ec2_key_name = var.ec2_key_name
#   # associate_public_ip_address = true
#   vpc_security_group_ids = [
#     module.demo_app_sg.this_security_group_id
#   ]
#   vpc_subnet_ids     = module.vpc.private_subnets
#   ec2_instance_count = 4
# }


