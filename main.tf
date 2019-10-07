provider "azurerm" {

}

module bigip {
    source              = "github.com/mjmenger/terraform-azure-bigip"

    prefix              = "bigip"
    f5_instance_count   = 1   
    #mgmt_subnet_security_group_ids = [sg-01234567890abcdef]
    #vpc_mgmt_subnet_ids = [subnet-01234567890abcdef]
}