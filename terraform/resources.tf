
# RESOURCES GROUP
## Creamos un resources group que agrupe todos los elementos del caso práctico
## De este modo liberar los recursos sólo requerirrá eliminar el grupo

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location_name
}

# CONTAINER REGISTRY
## Creamos el container registry indicado en el caso practico para alojar las imágenes de las aplicaciones a desplegar

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# VM
## Creamos la VM sobre la que desplegaremos una de la aplicaciones sobre podman

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.vm_specs.basename}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_specs.size
  admin_username      = var.vm_specs.admin_username
  network_interface_ids = [
    azurerm_network_interface.vnic.id,
  ]

  admin_ssh_key {
    username   = var.vm_specs.username
    public_key = file("${var.vm_specs.public_key}")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

#  plan {
#    name      = var.osimage_specs.name
#    product   = var.osimage_specs.product
#    publisher = var.osimage_specs.publisher
#  }

  source_image_reference {
    publisher = var.osimage_specs.publisher
    offer     = var.osimage_specs.offer
    sku       = var.osimage_specs.sku
    version   = var.osimage_specs.version
  }
}

## Será necesario crear una red y una subred para asociar a la NIC

resource "azurerm_virtual_network" "vnet" {
  name                = var.network_name
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/27"]
}

resource "azurerm_network_interface" "vnic" {
  name                = "vnic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

## Para la VM necesitaremos una IP pública

resource "azurerm_public_ip" "pip" {
  name                = "PIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Security Group
## Estableceremos un NSG para la VM donde añadirremos reglas para HTTP y SSH 

resource "azurerm_network_security_group" "nsg1" {
  name                = "securitygroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "httprule"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "sshrule"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg-link" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}
