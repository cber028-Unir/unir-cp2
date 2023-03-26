variable "resource_group_name" { default = "Unir-CP2" }
variable "location_name" { default = "uksouth" }
variable "acr_name" { default = "cber028UnirACR" }
variable "network_name" { default = "vnet1" }
variable "subnet_name" { default = "subnet1" }


#Variables para la VM

variable "vm_specs" {
  type = object({
    count          = string
    basename       = string
    size           = string
    admin_username = string
    username       = string
    public_key     = string
  })

  default = {
    count          = 1
    basename       = "cp2-vm"
    size           = "Standard_B1s"
    admin_username = "ubuntu"
    username       = "ubuntu"
    public_key     = "../keys-cp2/azure.pub"
  }
}



# Variables para el OS 
variable "osimage_specs" {
  type = object({
    name      = string
    product   = string
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })

  default = {
    name      = "Debian"
    product   = "debian-10"
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
