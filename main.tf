resource "random_id" "id" {
    byte_length = 2
}

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
                            environment = "demo"
                            costcenter  = "sales"
                            terraform    = "true"
                          }
}




